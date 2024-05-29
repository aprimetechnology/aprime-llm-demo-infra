#!/bin/bash

## Check necessary binaries are installed
commands=("aws" "python3.11" "pipenv" "terraform" "jq")

for cmd in "${commands[@]}"
do
	if ! command -v "$cmd" &> /dev/null
	then
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

# If any configurations are missing, print the messages and exit
if [ -n "$missing_config" ]; then
    echo -e "$missing_config"
    exit 1
fi

echo "Running: pipenv run cookiecutter ."
pipenv run cookiecutter .

# Get slug where the project was created
project_slug=$(jq -r '.project_slug' 'selected_values.json')
echo "Created terraform files in new directory: ${project_slug}"

cd $project_slug

echo "Running: terraform init"
terraform init

echo "Running: terraform apply"
terraform apply

echo "Don't forget to run the following when you are done from within the ${project_slug} directory: terraform destroy"
