# Quick start

This is how to quick start this project.  This guide is evolving and may be
missing some important details.  It is mostly appropriate for quickstarting
after you're able to successfully execute a `terraform apply` in the
`/terraform` directory.

# Get things going, verify

If infrastructure is not active, I recommend bringing it up with
```
$ terraform init    # This will likely be redundant, but terraform is good at being idempotent and this does need to be done at least once
$ terraform refresh # Make sure terraform is up-to-date with the remote state
$ terraform plan    # Skim the output, make sure it's what you expect
$ terraform apply   # Your infrastructure should be spinning up now
```
For a project of this scope, I recommend verifying the infrastructure is up and
running as expected in an outside channel.  For example, you can verify
terraform's state matches the actual running infra by checking the AWS console.
I tend to use the AWS console app for this.  If not deploying on AWS, your
provider should have similar functionality available, and over time you want to
build your own monitoring and logging suited to your production.  


