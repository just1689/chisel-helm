# chisel-helm
The unofficial Helm Chart for https://github.com/jpillora/chisel

The goal of this project is to provide a Helm chart for running Chisel in Kubernetes. Also supports HTTP path routing!

## TL;DR

Add the Helm repo
```bash

helm repo add captains-charts https://storage.googleapis.com/captains-charts
helm repo update

```

Create a values.yaml
```yaml
ingress:
  enabled: true
  nginxRewrite: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: nginx
  host: mycluster.local
  path: /chisel
  tls:
    secretName: mycluster-local-tls-secret
```

Install using the `values.yaml`
```bash

helm install --namespace=default --values values.yaml chisel captains-charts/chisel
chisel client https://mycluster.local 5000:some-remote:4200


```


## Uninstalling
```bash

helm delete --namespace=default chisel
# OR
helm delete MY-RELEASE

```

## Parameters

### Required parameters

| Parameter                      | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ----- |
| `ingress.host` | The host that the cluster  | `` |

### Chisel specific parameters

| Parameter                      | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ----- |
| `args.auth` | See Chisel docs | `` |
| `args.host` | See Chisel docs | `` |
| `args.key` | See Chisel docs | `` |
| `args.authFile` | See Chisel docs - Not implemented yet | |
| `args.keepalive` | See Chisel docs | `0s` |
| `args.backend` | See Chisel docs | `` |
| `args.socks5` | See Chisel docs | `` |
| `args.tls.key` | See Chisel docs | `` |
| `args.tls.cert` | See Chisel docs | `` |
| `args.tls.domain` | See Chisel docs | `` |
| `args.tls.ca` | See Chisel docs | `` |
| `args.verbose` | See Chisel docs | `false` |


### Optional parameters

| Parameter                      | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ----- |
| `replicaCount`    | How many replicas of Chisel to run                    | `1` |
| `image.repository` | The Docker image to run | jpillora/chisel  |
| `image.pullPolicy` | The image pull policy for the Chisel Docker image container | `IfNotPresent` |
| `image.tag` | The Docker tag (comes after the `:`). | Defaults to the chart `appVersion` |
| `image.customRegistry` | The pre-pended container registry for the image. For example: `gchr.io` | `` |
| `imagePullSecrets` | The image pull secrets field for the deployment | `` |
| `nameOverride` | Used to override the name | `` |
| `fullNameOverride` | Used to override the full name of the release | `` |
| `podAnnotations` | Used to add annotations to each pod deployed by this chart | `` |
| `podSecurityContext` | The pod security context will be used by the container runtime | `` |
| `securityContext` | The security context will be used by the container runtime | `` |
| `service.type` | The Kubernetes Service type field | `ClusterIP` |
| `service.port` | The port of the Kubernetes service that selects the pods running Chisel | `80` |
| `ingress.enabled` | Allows generation of Kubernetes Ingress object | `true` |
| `ingress.annotations` | Annotations added to the Ingress object | `` |
| `ingress.nginxRewrite` | Used when you require a context root for Chisel. For example `/chisel` | `false` |
| `ingress.tls.secretName` | The name of the Kubernetes secret to store the TLS secret for Ingress | `` |
| `resources.requests.cpu` | The requested CPU per container | `10m` |
| `resources.requests.memory` | The requested memory per container | `16Mi` |
| `resources.limits.cpu` | The CPU limit per container | `100m` |
| `resources.limits.memory` | The memory limit per container | `64Mi` |
| `resources` | The Kubernetes `resources` section for CPU and memory requests and memory | `` |
| `resources` | The Kubernetes `resources` section for CPU and memory requests and memory | `` |
| `nodeSelector` | See Kubernetes docs | `` |
| `tolerations` | See Kubernetes docs | `` |
| `affinity` | See Kubernetes docs | `` |
