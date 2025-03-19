terraform-aws-aurora-cluster
============================

Terraform module of Amazon Aurora Serverless v2

[![CI](https://github.com/dceoy/terraform-aws-aurora-cluster/actions/workflows/ci.yml/badge.svg)](https://github.com/dceoy/terraform-aws-aurora-cluster/actions/workflows/ci.yml)

Installation
------------

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/terraform-aws-aurora-cluster.git
    $ cd terraform-aws-aurora-cluster
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

7.  Create an IAM authentication user in the Aurora cluster using AWS CodeBuild.

    ```sh
    $ aws codebuild start-build \
        --project-name slc-dev-codebuild-project \
        --buildspec-override file://initilize.buildspec.yml
    ```

Cleanup
-------

```sh
$ terragrunt run-all destroy --working-dir='envs/dev/' --non-interactive
```
