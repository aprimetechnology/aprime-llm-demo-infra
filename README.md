# aprime-llm-demo-infra
A demo repo that uses our module to spin up a private AI Large Language Model (LLM) in an AWS account. There is an accompanying blog series that contains details on why we built this, why it makes sense for a team to host a model themselves, how to get started, and any specific details of our implementation.

**Blog Series:**
1. [Part 1: How to host your own private AI models in AWS](https://www.aprime.com/how-to-host-your-own-private-ai-models-in-aws/)
2. [Part 2: Quickstart Guide to Self-Hosting AI Models in AWS](https://www.aprime.com/quickstart-guide-to-self-hosting-ai-models-in-aws/)
3. [Part 3: In-Depth Walkthrough of Self-Hosted AI Setup](https://www.aprime.com/in-depth-walkthrough-of-self-hosted-ai-setup/)



## Requirements
This script requires:
- aws account
- aws cli
- python3.11
- pipenv
- terraform
- jq
- a domain registered

Additionally, it requires that your `aws` cli is configured with an access_key, secret_key, and region.

See more detailed instructions on **[prerequisites](https://www.aprime.com/quickstart-guide-to-self-hosting-ai-models-in-aws/#prerequisites)** within our quickstart guide.

## Setup
We recommend that you request the ability to launch 8 `G and VT Spot Instances` via AWS prior to running the quickstart. *Our quickstart script will help you do this request automatically , but it may take a little bit of time for AWS to grant it.*

To start the setup (*quickstart*) script for the demo LLM, run the following command:

`./quickstart.sh`

To streamline the deployment process, we recommend using our [open-source Terraform module](https://github.com/aprimetechnology/terraform-text-generation-inference-aws). This will guide you through setting this up.

We also recommend that you have a domain that you can use for creating an ALB + Route 53 records to use SSL with the UI. If you do **not** have a domain, the quickstart will use HTTP to access the ALB url. This is **NOT** recommended for production use-cases.

 This module automates most of the steps required and makes it easier to get started. If you would like to see a more detailed guide of the steps and discussion of any decisions made within the module, please read the companion [quickstart guide](https://www.aprime.com/quickstart-guide-to-self-hosting-ai-models-in-aws/) on our [website](https://www.aprime.com/).

## Cleanup
We provide a `cleanup.sh` script, which will remove all the things we created, including:
- Everything created by the `terraform apply`
- The S3 bucket for terraform state storage, if we created it for you.

## Share Your Ideas & Stay Connected
We are excited to hear about your experience of setting up your own models in AWS, and any feedback or ideas on how we can further improve these tools. Here’s how you can stay connected and contribute to the project:

* Email Us: Reach out with any questions, feedback, or support requests at [llm@aprime.io](mailto:llm@aprime.io).
* Follow Us on LinkedIn/GitHub: Stay updated with the latest developments and connect with our community by following us on [LinkedIn](https://www.linkedin.com/company/aprimeio/) or [GitHub](https://github.com/aprimetechnology/).

⭐️ **Star the Repo or Open an Issue:** You can participate in the project by reporting issues, suggesting features, or simply showing your support for our repo.

## APrime
We hope you find the provided modules and Terraform workflows useful in your first steps to hosting your own model and keeping your proprietary data safe. [APrime](https://www.aprime.com/) operates with companies of all sizes and provide flexible engagement models, ranging from flex capacity and fractional leadership to fully embedding our team at your company. We are passionate about innovating with AI/LLMs and love solving tough problems, shipping products and code, and being able to see the tremendous impact on both our client companies and their end users.

No matter where you are in your AI journey, [schedule a call](https://www.aprime.com/contact/#contact-form) with our founders today to explore how we can make use of this powerful technology together!

[<img src="https://www.aprime.io/wp-content/uploads/2023/08/Aprime_logo@0.5x-1.png" width=225/>](https://www.aprime.com/)
