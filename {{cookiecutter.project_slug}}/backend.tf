{%- if cookiecutter.s3_bucket %}
terraform {
  backend "s3" {
    bucket = "{{ cookiecutter.s3_bucket }}"
    key    = "{{ cookiecutter.project_slug }}/terraform.tfstate"
    region = "{{ cookiecutter.region }}"
  }
}
{%- endif %}
