# terraform module for ArgoCD

## Usage
TODO
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_keys | n/a | `map(any)` | `{}` | no |
| bootstrap\_path | n/a | `list(string)` | `null` | no |
| chart\_version | n/a | `string` | n/a | yes |
| cluster\_manifest | n/a | `string` | `null` | no |
| namespace | n/a | `string` | `"argocd"` | no |
| release\_name | n/a | `string` | `"argo-cd"` | no |
| values | n/a | `list(string)` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
