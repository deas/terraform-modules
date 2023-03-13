# Birth place for my small random terraform modules

I drop small terraform modules here - small in the sense that they don't deserve their own repo yet.

For the most part, the modules came to life in the context of work around GitOps based Continous Delivery starting `@localhost`. They mostly revolve around `flux`, `argocd`, `terraform` and `kind` technically. 

Projects leveraging the modules include:

- [flux-conductr](https://github.com/deas/flux-conductr) : Focuses on the `flux` bit in `flux` based GitOps. (Initial project)
- [argocd-conductr](https://github.com/deas/argocd-conductr) : Focuses on the `argocd` bit in `argocd` based GitOps. (Currently Small compared to its `flux` counterpart)
- [ka0s](https://github.com/deas/ka0s) : Focuses on a [`Litmus`](https://litmuschaos.io/) based platform supported by `flux`.

The projects themselves aim at providing a GitOps deployable solution.

## TODO
- Introduce tests (e.g. `terratest`)
- Introduce proper versioning
