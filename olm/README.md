# terraform module for Kubernetes OLM

⚠️: Deprecated, use `helm_release` with [OLM chart instead](https://github.com/CloudTooling/k8s-olm) instead

## Usage
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | n/a | `string` | `"olm"` | no |
| url\_olm | n/a | `string` | `"https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.30.0/olm.yaml"` | no |
| url\_olm\_crds | TODO: Downloading from releases causes content type warning - ugly, but at least transparent | `string` | `"https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.30.0/crds.yaml"` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
