terraform-aws-aurora-data-api
=============================

Terraform module of Amazon Aurora Serverless v2 with RDS Data API

[![CI](https://github.com/dceoy/terraform-aws-aurora-data-api/actions/workflows/ci.yml/badge.svg)](https://github.com/dceoy/terraform-aws-aurora-data-api/actions/workflows/ci.yml)

Installation
------------

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/terraform-aws-aurora-data-api.git
    $ cd terraform-aws-aurora-data-api
    ````

2.  Install [AWS CLI](https://aws.amazon.com/cli/) and set `~/.aws/config` and `~/.aws/credentials`.

3.  Install [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/).

4.  Initialize Terraform working directories.

    ```sh
    $ terragrunt run-all init --working-dir='envs/dev/' -upgrade -reconfigure
    ```

5.  Generates a speculative execution plan. (Optional)

    ```sh
    $ terragrunt run-all plan --working-dir='envs/dev/'
    ```

6.  Creates or updates infrastructure.

    ```sh
    $ terragrunt run-all apply --working-dir='envs/dev/' --non-interactive
    ```

Cleanup
-------

```sh
$ terragrunt run-all destroy --working-dir='envs/dev/' --non-interactive
```
