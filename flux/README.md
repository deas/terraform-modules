# terraform module for flux

## Usage
TODO
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_keys | n/a | `map(any)` | `{}` | no |
| bootstrap\_manifest | n/a | `string` | `null` | no |
| kustomization\_path | n/a | `string` | n/a | yes |
| namespace | n/a | `string` | `"flux-system"` | no |
| tls\_key | n/a | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
[flux](https://fluxcd.io/)
