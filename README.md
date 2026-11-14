# terraform-aws-pilgrim

Terraform for pilgrim.farm, run through Terragrunt. State lives in S3
(`pilgrim-dot-farm-tfstate`, us-west-2, versioned, native lockfile locking),
one state object per unit.

## Layout

| Path | Purpose |
| --- | --- |
| `modules/network` | Default-VPC lookups, private subnets, NAT, all security groups and rules |
| `modules/data` | Application S3 buckets, CloudFront, RDS, ElastiCache |
| `modules/identity` | Application IAM role/users/policies, Stripe secret |
| `modules/app` | ACM certificate, ALB, EC2 instance and EIP, ECS cluster/service |
| `live/root.hcl` | Shared Terragrunt config: Terraform binary, provider, S3 backend |
| `live/prod/env.hcl` | Account, state bucket, values shared across units |
| `live/prod/us-west-2/<unit>` | One deployable unit per module |
| `bootstrap/state` | The state bucket itself (plain Terraform, state in the same bucket) |

Dependencies: `network → data → identity → app` (app also reads network and data directly).

## Prerequisites

- Terraform 1.17.x and Terragrunt 1.2.x. `live/root.hcl` pins Terragrunt to `terraform`, not OpenTofu.
- AWS credentials for the target account in your shell.
- `live/prod/private.hcl` and `bootstrap/state/terraform.tfvars` (both git-ignored; copy the `.example` files) holding the AWS account ID and admin IP.
- `secrets/prod/stripe.json` (git-ignored) holding the Stripe credentials for the identity unit.

## Everyday commands

```sh
# One unit
cd live/prod/us-west-2/app
terragrunt plan
terragrunt apply
terragrunt output

# Everything, in dependency order
cd live/prod/us-west-2
terragrunt run --all -- plan
```

Release bump: edit `ecs_release` (and/or `ecs_container_image`) in
`live/prod/us-west-2/app/terragrunt.hcl`, then `terragrunt apply` in that directory.

Outputs moved with their resources: `ssh_command`, `elastic_ip`, `instance_id` are in `app`;
bucket names, CloudFront, database and cache outputs are in `data`; `security_group_id` is in `network`;
`mac_studio_user_arn` is in `identity`.

## Recovery

The bucket is versioned, so every state write keeps its predecessor. The pre-split
monolith state (serial 244) is the last `modules/ec2/terraform.tfstate` in Git history.
