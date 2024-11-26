# terraform module for ArgoCD

## Usage
TODO
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_keys | n/a | `map(any)` | `{}` | no |
| argocd\_instance | n/a | `string` | n/a | yes |
| bootstrap\_path | n/a | `string` | `null` | no |
| cluster\_manifest | n/a | `string` | `null` | no |
| namespace | n/a | `string` | `"argocd"` | no |
| subscription | n/a | <pre>object({<br>    yaml_body    = string<br>    crd_dep_hack = string<br>  })</pre> | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
