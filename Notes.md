# AWS Terraform Solution

The solution will create a VPC with a public subnet in each AZ in a region. A single EC2 instance is deployed in each AZ available in the region the deployment is specified for.

The EC2 instance(s) will install Nginx web server in its default state and will display the default welcome page, this can be viewed in the browser using the ELB DNS endpoint.

## Configuration
1. Create your SSH key pair and add the path to the variable `public_key` located in variables.tf.
2. Amend the CIDR range to your IP and change the variable `bastion_cidr` located in variables.tf.

## Run Terraform
To run terraform use the following command from the terraform directory:

```bash
terraform init -var-file=dublin.tfvars
```

```bash
terraform apply -var-file=dublin.tfvars
```

To run the same configuration in the Virginia region, run the following command:

```bash
terraform apply -var-file=virginia.tfvars
```

## Cleanup

To cleanup, execute the below command from the terraform directory.

```bash
terraform destroy -var-file=dublin.tfvars
```