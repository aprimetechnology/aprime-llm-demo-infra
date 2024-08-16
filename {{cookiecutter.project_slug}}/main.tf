provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = "{{cookiecutter.region}}"
  name   = "{{cookiecutter.name}}"

  domain = "{{cookiecutter.domain}}"

  vpc_cidr                                 = "10.0.0.0/16"
  azs                                      = slice(data.aws_availability_zones.available.names, 0, 3)
  text_generation_inference_discovery_name = "text-generation-{{cookiecutter.name}}"
  text_generation_inference_port           = 11434
  nginx_port                               = 80

  tags = {
    Name    = local.name
    Example = local.name
  }
}

##############################################################
# Text Generation Inference
##############################################################

module "text_generation_inference" {
  source = "git@github.com:aprimetechnology/terraform-text-generation-inference-aws.git?ref=0.0.3"

  name = "${local.name}-tgi"

  text_generation_inference_discovery_name      = local.text_generation_inference_discovery_name
  text_generation_inference_discovery_namespace = aws_service_discovery_http_namespace.this.name

  text_generation_inference = {
    port          = local.text_generation_inference_port
    image_version = "2.0.3"
  }
  nginx = {
    port = local.nginx_port
  }
  instance_type = "g4dn.2xlarge"
  quantize      = "bitsandbytes"

  vpc_id             = module.vpc.vpc_id
  availability_zones = local.azs

  # ECS
  service = {
    # enable AWS Exec support by default so ECS containers can be Exec'd into
    enable_execute_command             = true
    deployment_minimum_healthy_percent = 0
    service_connect_configuration = {
      enabled   = true
      namespace = aws_service_discovery_http_namespace.this.arn
      service = {
        client_alias = {
          # We proxy through the nginx container so Open WebUI can access the
          # mocked /v1/models endpoint which is required for its operation.
          port = local.nginx_port
        }
        port_name      = "http-proxy"
        discovery_name = local.text_generation_inference_discovery_name
      }
    }
  }
  service_subnets    = module.vpc.private_subnets
  alb_subnets        = module.vpc.public_subnets
  use_spot_instances = true

  # ALB
  create_alb = false

  # ACM
  create_certificate = false

  # Open WebUI
  use_ssl_ui = {{ "true" if cookiecutter.domain else "false" }}

  {%- if cookiecutter.domain %}
  route53_zone_id   = data.aws_route53_zone.this.zone_id
  route53_zone_name = data.aws_route53_zone.this.name
  {%- endif %}

  # EFS
  enable_efs = true
  efs = {
    mount_targets = {
      for idx, az in local.azs : az => {
        subnet_id = module.vpc.private_subnets[idx]
      }
    }
  }

  tags = local.tags
}


################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

##############################################################
# Route53
##############################################################
{%- if cookiecutter.domain %}
data "aws_route53_zone" "this" {
  name = local.domain
}
{%- endif %}

##############################################################
# Service Discovery
##############################################################

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}
