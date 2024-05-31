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
cd $project_slug
terraform destroy

cd ..

# Check if we created the S3 bucket for them
if [[ -f "$CREATED_BUCKET_FILE" ]]; then
    CREATED_BUCKET_NAME=$(cat "$CREATED_BUCKET_FILE")
    read -p "Delete $CREATED_BUCKET_NAME that we created? (yes/no): " user_input
    if [[ "$user_input" == "yes" ]]; then
        # Deleting contents of the bucket
        aws s3 rm s3://"$CREATED_BUCKET_NAME" --recursive
        aws s3api delete-bucket --bucket "$CREATED_BUCKET_NAME" --region "$aws_region"

        echo "Successfully deleted: $CREATED_BUCKET_NAME"
    fi
fi
