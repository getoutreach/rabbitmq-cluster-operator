# RabbitMQ Cluster Operator

These manifests control the deployment of the RabbitMQ cluster operator agent into our Kubernetes clusters.
## How this works

This repo is structured like so:

* `imports/` - Contains various jsonnet snippets for mixin like components, e.g. rules for log processing or metrics gathering. See [Imports](#imports) for more information.
* `charts/` - Contains the vendored helm chart for the Rabbit Cluster Operator agent. Eventually this will be removed and replaced with ArgoCD pulling these down on the fly.
* `tests/` - Contains various tests for the jsonnet.
* `scripts/` - Contains scripts for interacting with the agent. Currently contains the chart vendor script (`sync-charts.sh`) and the validation script (`validate-jsonnet.sh`)
* `rabbitmq-cluster-operator.jsonnet` - The main entrypoint for the jsonnet. This is where we import the helm chart and apply our mixins.
* `hostlogs.jsonnet` - Configuration for what logs to collect from the host and various cardinality restrictions/inclusions.

### Helm Chart

This uses [`tk`](https://tanka.dev) to vendor a helm chart into our repository through `tk charts vendor`. We then use `importbin` to import the helm chart into our jsonnet files. Using `kubecfg.parseHelmChart` we render it into kubernetes manifests a deploy time. From there, all of the standard jsonnet "magic" applies.

## Upgrading

**Note:** The latest helm chart can be found at [the artifact hub](https://artifacthub.io/packages/helm/bitnami/rabbitmq-cluster-operator).

### Required Dependencies

* [`tk`](https://tanka.dev) - Used to vendor the helm chart into our repository. `brew install tanka`
* [`kubecfg`](https://github.com/kubecfg/kubecfg) - Used to render jsonnet into Kubernetes manifests. `brew install kubecfg`
* [`dyff`](https://github.com/homeport/dyff) - Used to generated yaml friendly diffs. `brew install homeport/tap/dyff`
* [`kubeconform`](https://github.com/yannh/kubeconform) - Used to validate the rendered manifests. `brew install kubeconform`
* ['helm'](https://helm.sh) - Used to vendor the helm chart into our repository. `brew install helm`

### Process

1. Update the version in `charts/chartfile.yaml` and the import string in `rabbitmq-cluster-operator.jsonnet`.
2. Run `./scripts/sync-charts.sh` to vendor the helm chart into `charts/`.
3. Run `./scripts/validate-jsonnet.sh` to show the differences between the last version. If everything passes a sanity check, delete the snapshot file `tests/basic/snapshot.yaml` and run the validate script again to regenerate it.
4. Commit the changes and open a PR.