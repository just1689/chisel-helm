# chisel-helm
The unofficial Helm Chart for jpillora's Chisel. See more about Chisel at https://github.com/jpillora/chisel

The goal of this project is to provide a Helm chart for running Chisel in Kubernetes. Also supports HTTP path routing!

This chart creates kubernetes *services* for the ports forwarded by chisel

## TL;DR

Add the Helm repo
```bash

helm repo add captains-charts https://storage.googleapis.com/captains-charts
helm repo update

```

As you might see on the samples the `services` sections are the same on server & client side - so you just can copy them between the client and server side if you use chisel vor cluster interconnection.

### Run as server

Create a values-server.yaml
```yaml
mode: server
ingress:
  enabled: true
  nginxRegex: true
  nginxRewrite: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: nginx
  host: mycluster.local
  path: /chisel
  tls:
    secretName: mycluster-local-tls-secret

args:
  reverse: true

clients:
- user: sample1
  password: sample1secret
  services:
    default:
    - mode: to-client
      port: 673
      endpoint: rsync.svc:673
    - mode: to-server
      port: 25
      name: smtp
      endpoint: smtp-in:25
    remote-api:
    - mode: to-client
      port: 6443
      endpoint: kubernetes.default.svc:443
    services:
    - mode: to-server
      port: 6080
      endpoint: services:80
      servicePort: 80
    ^serviceWithTwoPorts:
    - mode: to-client
      port: 6080
      endpoint: services:80
      servicePort: 80
    - mode: to-client
      port: 6444
      endpoint: services:443
      servicePort: 443
- user: sample2
  password: sample2se"e'$acret
  services:
    remote-api:
    - mode: to-client
      port: 7443
      endpoint: kubernetes.default.svc:443
      serviceType: LoadBalancer
      externalIPs:
      - 192.168.1.10
      externalTrafficPolicy: Local
    services:
    - mode: to-server
      port: 6080
      endpoint: services:80
      serviceName: services
      servicePort: 80

securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
```

Install using the `values-server.yaml`
```bash

helm install --namespace=default --values values-server.yaml chisel captains-charts/chisel
chisel client https://mycluster.local/chisel 5000:some-remote:4200

```

### Run as client

Create a values-client.yaml
```yaml
mode: client

credentials:
  user: sample1
  password: sample1secret

args:
  server: https://mycluster.local/chisel/

services:
  default:
  - mode: to-client
    port: 673
    endpoint: rsync.svc:673
  - mode: to-server
    port: 25
    name: smtp
    endpoint: smtp-in:25
  remote-api:
  - mode: to-client
    port: 6443
    endpoint: kubernetes.default.svc:443
  services:
  - mode: to-server
    port: 6080
    endpoint: services:80
    servicePort: 80
  ^serviceWithTwoPorts:
  - mode: to-client
    port: 6080
    endpoint: services:80
    servicePort: 80
  - mode: to-client
    port: 6444
    endpoint: services:443
    servicePort: 443

securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
```

Install using the `values-client.yaml`
```bash

helm install --namespace=default --values values-client.yaml chisel captains-charts/chisel

```



## Uninstalling
```bash

helm delete --namespace=default chisel
# OR
helm delete MY-RELEASE

```

## Parameters

### Core parameters

| Parameter                      | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ----- |
| `mode` | Chisel operation mode - `"client"` or `"server"`  |`"server"` |


### Required parameters for "`server"`

| Parameter                      | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ----- |
| `ingress.host` | The host that the cluster  | `` |
| `clients[].user` | The user name for this client | `` |
| `clients[].password` | The password this client | `` |
| `clients[].services` | Allowed services for this client. See [Chisel Service Definition](#chisel-service-definition) for details | `{}` |

### Chisel `"server"` specific parameters

| Parameter                      | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ----- |
| `args.auth` | See Chisel docs | `` |
| `args.host` | See Chisel docs | `` |
| `args.key` | See Chisel docs | `` |
| `args.authFile` | See Chisel docs - Not implemented yet | |
| `args.keepalive` | See Chisel docs | `0s` |
| `args.backend` | See Chisel docs | `` |
| `args.reverse` | See Chisel docs | `` |
| `args.socks5` | See Chisel docs | `` |
| `args.tls.key` | See Chisel docs | `` |
| `args.tls.cert` | See Chisel docs | `` |
| `args.tls.domain` | See Chisel docs | `` |
| `args.tls.ca` | See Chisel docs | `` |
| `args.verbose` | See Chisel docs | `false` |

### Chisel `"client"` specific parameters

#### Required parameters for "`client"`

| Parameter                      | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ----- |
| `args.server` | The server URL   | `""` |

#### parameters for "`client"`

| Parameter                      | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ----- |
| `credentials.user` | Used for the client authentication | `""` |
| `credentials.password` | Used for the client authentication | `""` |
| `services` | Services to provide. See [Chisel Service Definition](#chisel-service-definition) for details | `{}` |
| `args.fingerprint` | See Chisel docs | `` |
| `args.key` | See Chisel docs | `` |
| `args.keepalive` | See Chisel docs | `0s` |
| `args.maxRetryCount` | See Chisel docs `max-retry-count` | `` |
| `args.maxRetryInterval` | See Chisel docs `max-retry-interval` | `` |
| `args.proxy` | See Chisel docs | `` |
| `args.header` | See Chisel docs | `` |
| `args.hostname` | See Chisel docs | `` |
| `args.tls.ca` | See Chisel docs | `` |
| `args.tls.skipVerify` | See Chisel docs `tls-skip-verify` | `` |
| `args.tls.key` | See Chisel docs | `` |
| `args.tls.cert` | See Chisel docs | `` |
| `args.verbose` | See Chisel docs | `false` |

### Chisel service definition

The `services` object defines which services / ports are forwarded between client and server.

The key is the name of the service object. When it starts with `^` the name given is used as name vor the service definition. If it doesn't start with the `^` prefix the service object name will be prefixed with the helm name prefix. The key `default` just adds the service to the default service object created. Please keep in mind: for the `server` mode port 80 is blocked for http ingress!

For each service name / key an array of services can be defined. Each service definition has following set of options:

| Name                      | Description                                     |
| ------------------------- | ----------------------------------------------- |
| `mode`    | The direction for this service. Either `to-client` or `to-server`. **Required**  |
| `port`    | The port chisel should bind on for this service **Required** |
| `servicePort` | The port this service should be exposed on the service object. Defaults to `port` if omitted. |
| `endpoint` | The destination to which chisel forwards this service. **required** |
| `name` | Custom name of this service within the service |
| `serviceType` | Only valid on first entry: Sets `type` for the kubernetes service definition. Defaults to `ClusterIP` |
| `clusterIP` | Only valid on first entry: Sets `clusterIP` on the kubernetes service definition when `type=LoadBalancer` |
| `loadBalancerIP` | Only valid on first entry: Sets `loadBalancerIP` on the kubernetes service definition when `type=LoadBalancer` |
| `externalTrafficPolicy` | Only valid on first entry: Sets `externalTrafficPolicy` on the kubernetes service definition. |
| `loadBalancerSourceRanges` | Only valid on first entry: Sets `loadBalancerSourceRanges` on the kubernetes service definition. |
| `sessionAffinity` | Only valid on first entry: Sets `sessionAffinity` on the kubernetes service definition. |
| `externalIPs` | Only valid on first entry: Sets `externalIPs` on the kubernetes service definition. |
| `publishNotReadyAddresses` | Only valid on first entry: Sets `publishNotReadyAddresses` on the kubernetes service definition. |

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
| `ingress.nginxRegex` | When you want to apply regex matching for the Chisel path. | `false` |
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
