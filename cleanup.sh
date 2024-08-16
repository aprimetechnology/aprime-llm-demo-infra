#!/bin/bash
#

# Exit if a command exits with a non-zero status
# Ensures we don't delete S3 bucket if terraform destroy fails
set -e

CREATED_BUCKET_FILE="created_bucket.txt"

# Get slug where the project was created
project_slug=$(jq -r '.project_slug' 'selected_values.json')
aws_region=$(aws configure get region)

echo "Going to cleanup terraform in the $project_slug directory"
cd "$project_slug" || exit
terraform destroy

cd .. || exit

# Check if we created the S3 bucket for them
if [[ -f "$CREATED_BUCKET_FILE" ]]; then
    CREATED_BUCKET_NAME=$(cat "$CREATED_BUCKET_FILE")
    read -rp "Delete $CREATED_BUCKET_NAME bucket that we created? (yes/no): " user_input
    if [[ "$user_input" == "yes" ]]; then
        # Deleting contents of the bucket
        aws s3 rm s3://"$CREATED_BUCKET_NAME" --recursive
        aws s3api delete-bucket --bucket "$CREATED_BUCKET_NAME" --region "$aws_region"

        echo "Successfully deleted: $CREATED_BUCKET_NAME"
        rm created_bucket.txt
    else
        echo "Not deleting created S3 bucket, feel free to run this on your own:"
        echo "aws s3api delete-bucket --bucket $CREATED_BUCKET_NAME --region $aws_region"
    fi
fi

rm selected_values.json
