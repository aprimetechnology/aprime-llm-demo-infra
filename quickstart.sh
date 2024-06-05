#!/bin/bash
set -e
## Check necessary binaries are installed
commands=("aws" "python3.11" "pipenv" "terraform" "jq")

for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "$cmd is not installed. Please install it first."
        exit 1
    fi
done

# Get the aws configuration
aws_config=$(aws configure list)

# Initialize a variable to collect missing configuration messages
missing_config=""

if ! echo "$aws_config" | grep -q "access_key"; then
    missing_config+="No aws access_key configured\n"
fi

if ! echo "$aws_config" | grep -q "secret_key"; then
    missing_config+="No aws secret_key configured\n"
fi

if ! echo "$aws_config" | grep -q "region"; then
    missing_config+="No aws region configured\n"
fi

aws_region=$(aws configure get region)

# If any configurations are missing, print the messages and exit
if [ -n "$missing_config" ]; then
    echo -e "$missing_config"
    exit 1
fi

# Checking that you have the necessary instances
QUOTA_CODE="L-3819A6DF"

QUOTA_JSON=$(aws service-quotas get-service-quota --service-code ec2 --quota-code "$QUOTA_CODE")
QUOTA=$(echo "$QUOTA_JSON" | jq -r '.Quota.Value')
QUOTA_NAME=$(echo "$QUOTA_JSON" | jq -r '.Quota.QuotaName')

# Convert Quota to an int
CURRENT_QUOTA_INT=$(printf "%.0f" "$QUOTA")

if ((CURRENT_QUOTA_INT < 8)); then
    echo "Quota ($QUOTA_NAME) isn't at least 10: $CURRENT_QUOTA_INT"
    read -rp "We need this amount to run the LLM, would you like us to request an increase in your quota? (yes/no): " user_input

    if [[ "$user_input" != "yes" ]]; then
        echo "Not requesting increase, feel free to run this on your own:"
        echo "aws service-quotas request-service-quota-increase --service-code ec2 --quota-code $QUOTA_CODE --desired-value 8"
        exit 1
    fi
    echo "Requesting increase..."
    aws service-quotas request-service-quota-increase --service-code ec2 --quota-code "$QUOTA_CODE" --desired-value 8 --no-cli-pager
    echo "You can check on the status of your quota request here: https://$aws_region.console.aws.amazon.com/servicequotas/home/requests"
    echo
    echo "Going ahead with standing up LLM, the EC2 instances won't spin up until the quota increase is approved."
fi

# Check that you have a domain
domains=$(aws route53domains list-domains --region us-east-1)
num_domains=$(echo "$domains" | jq '.Domains | length')

if [[ $num_domains -eq 0 ]]; then
    echo "No domains are registered which you will need for the UI."
    echo "Please register one at: https://us-east-1.console.aws.amazon.com/route53/domains/home"
else
    echo "Domains available:"
    echo "$domains" | jq '.Domains[].DomainName'
fi

# Only run cookiecutter on the first time
if [[ ! -f "selected_values.json" ]]; then
    echo "Running: pipenv run cookiecutter ."
    pipenv run cookiecutter .
fi

# Get slug where the project was created
project_slug=$(jq -r '.project_slug' 'selected_values.json')
echo "Terraform files are in new directory: ${project_slug}"

# Ensure there's a hosted zone for the domain
selected_domain=$(jq -r '.domain' 'selected_values.json')
hosted_zone=$(aws route53 list-hosted-zones | jq --arg name "$selected_domain." '.HostedZones[] | select(.Name == $name) | .Id')

if [[ $selected_domain && -z "$hosted_zone" ]]; then
    echo "No hosted zone exists for $selected_domain."
    echo "Please create one up at: https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones"
    exit 1
fi

s3_bucket=$(jq -r '.s3_bucket' 'selected_values.json')

# If a user specified a bucket, check if it exists and create it
# if it doesn't.
if [[ -n "$s3_bucket" && "$s3_bucket" != "null" ]]; then
    echo "Checking if bucket ($s3_bucket) exists..."
    if aws s3api head-bucket --bucket "$s3_bucket" --no-cli-pager 2>/dev/null; then
        echo "Bucket $s3_bucket" already exists
    else
        echo "Bucket $s3_bucket doesn't appear to exist, attempting to create it"
        if aws s3api create-bucket --bucket "$s3_bucket" --region "$aws_region" --create-bucket-configuration LocationConstraint="$aws_region" --no-cli-pager; then
            echo "Bucket $s3_bucket created successfully."
            echo "$s3_bucket" >created_bucket.txt
        else
            echo "Failed to create $s3_bucket"
            exit 1
        fi
    fi
fi

cd "$project_slug" || exit

echo "Running: terraform init"
terraform init

echo "Running: terraform apply"
terraform apply

echo "Don't forget to run the following when you are done: ./cleanup.sh"

# Get the URL
alb_dns_name=$(terraform output -raw alb_dns_name)
ui_url=$(terraform output -raw ui_url)

URL=""
if [[ -n "$tf_ui_url" ]]; then
    URL="https://$ui_url"
else
    URL="http://$alb_dns_name"
    echo "Since you aren't using a domain, there is no HTTPS. Add a domain (which includes HTTPS) prior to using in production."
fi

echo "Checking UI ($URL) is up!"

TIMEOUT=$((10 * 60))
INTERVAL=30
MAX_ATTEMPTS=$((TIMEOUT / INTERVAL))

for ((i = 1; i <= MAX_ATTEMPTS; i++)); do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "$URL is up!"
        break
    fi
    sleep $INTERVAL
done

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "The URL was never ready within the timeout period."
    exit 1
fi

echo "Go to $URL and sign up for an account. The first email + password you put in will create an admin account!"
