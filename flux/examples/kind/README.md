# terraform example for flux on kind

## Usage
```shell
cp sample.tfvars terraform.tfvars
# Set proper values in terraform.tfvars
terraform apply
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_keys | n/a | `map(any)` | `{}` | no |
| filename\_flux\_path | n/a | `string` | `"../simple/clusters/local/flux-system"` | no |
| flux\_branch | branch name | `string` | `"main"` | no |
| flux\_github\_owner | github owner | `string` | n/a | yes |
| flux\_repository\_name | github repository name | `string` | n/a | yes |
| id\_rsa\_fluxbot\_ro\_path | n/a | `string` | n/a | yes |
| id\_rsa\_fluxbot\_ro\_pub\_path | n/a | `string` | n/a | yes |
| target\_path | flux sync target path | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster | Object describing the whole created project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
