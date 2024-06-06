# aprime-llm-demo-infra
A demo repo that uses our module to spin up a personal LLM.

## Requirements
This script requires:
- aws
- python3.11
- pipenv
- terraform
- jq

Additionally, it requires that your `aws` cli is configured with an access_key, secret_key, and region.

## Setup
We recommend that you request the ability to launch 8 `G and VT Spot Instances` via AWS prior to running the quickstart. Our script will help you do this request, but it may take a little bit of time for AWS to grant it.

We recommend that you have a domain that you can use for creating an ALB + Route 53 records to use SSL with the UI.
If you do **not** have a domain, the quickstart will use HTTP to access the ALB url. This is **NOT** recommended for production use-cases.

## Running the Demo
To run the demo, run the following:

`./quickstart.sh`

This will guide you through setting up the APrime [terraform-text-generation-inference-aws](https://github.com/aprimetechnology/terraform-text-generation-inference-aws) module.

## Cleanup
We also have a `cleanup.sh` script, which will remove all the things we created, including:
- Everything created by the `terraform apply`
- The S3 bucket for terraform state storage, if we created it for you.
