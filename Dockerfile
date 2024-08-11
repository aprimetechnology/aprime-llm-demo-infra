FROM python:3.11.9

# install pipenv, terraform, jq
RUN pip install pipenv
COPY --from=hashicorp/terraform:1.9.4 /bin/terraform /bin/terraform
COPY --from=ghcr.io/jqlang/jq /jq /usr/bin/jq

# install aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# install everything in the Pipfile
ADD Pipfile .
ADD Pipfile.lock .
RUN pipenv install --system

CMD ["bash"]
