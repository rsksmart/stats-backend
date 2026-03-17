# stats-backend Helm Chart

A Helm chart for deploying the RSK Network Stats Backend application on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- AWS Load Balancer Controller (for TargetGroupBinding)
- External Secrets Operator (for ExternalSecrets)

## Installation

The chart automatically creates the namespace defined in `values.namespace`, so no manual namespace creation is required.

### Basic Installation

```bash
# Install with default values (creates stats-backend namespace)
helm install stats-backend . -f values.yaml
```

### Environment-Specific Installation

```bash
# Development (creates stats-backend-dev namespace)
helm install stats-backend . -f values.yaml -f values-dev.yaml

# Production (creates stats-backend-prod namespace)
helm install stats-backend . -f values.yaml -f values-prod.yaml

# Testnet (creates stats-backend-testnet namespace)
helm install stats-backend . -f values.yaml -f values-testnet.yaml
```

### Upgrade

```bash
# Upgrade dev environment
helm upgrade stats-backend . -f values.yaml -f values-dev.yaml

# Upgrade prod environment
helm upgrade stats-backend . -f values.yaml -f values-prod.yaml
```

### Uninstall

```bash
helm uninstall stats-backend -n stats-backend
```

## Configuration

### Core Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `appName` | Application name used in image path and parameter store | `stats-backend` |
| `replicaCount` | Number of pod replicas | `2` |
| `namespace` | Target namespace for deployment | `stats-backend` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full chart name | `""` |

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | Container image registry | `654654249872.dkr.ecr.us-east-2.amazonaws.com` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `image.tag` | Image tag | `latest` |

### Environment Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env.nodeEnv` | Node environment (development, production) | `production` |
| `env.wsSecretKey` | Secret key name for WS_SECRET env var | `backend-password` |

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `NodePort` |
| `service.port` | Service port | `3000` |
| `service.targetPort` | Container port | `3000` |

### TargetGroupBinding Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `targetGroupBinding.enabled` | Enable TargetGroupBinding | `false` |
| `targetGroupBinding.targetGroupArn` | AWS Target Group ARN | `""` |
| `targetGroupBinding.targetType` | Target type (instance/ip) | `instance` |

### Resource Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

### External Secrets Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `externalSecrets.enabled` | Enable ExternalSecrets | `false` |
| `externalSecrets.envSuffix` | Environment suffix for parameter paths (dev, prod) | `""` |
| `externalSecrets.secrets` | List of secrets to fetch | See values.yaml |

## TargetGroupBinding

This chart uses TargetGroupBinding to register the service with an externally-managed AWS ALB (created by Terraform/CloudFormation).

```yaml
targetGroupBinding:
  enabled: true
  targetGroupArn: "arn:aws:elasticloadbalancing:region:account:targetgroup/name/xxx"
  targetType: instance
```

## External Secrets

This chart integrates with the External Secrets Operator to sync secrets from AWS Parameter Store.

### Prerequisites

1. External Secrets Operator installed in the cluster
2. Service account with IAM permissions to access Parameter Store

### Configuration

```yaml
externalSecrets:
  enabled: true
  envSuffix: dev  # Results in path: /stats-backend/dev/backend-password
  secrets:
    - secretKey: backend-password
      remoteKey: backend-password
```

The chart creates a `ClusterSecretStore` resource that configures AWS Parameter Store access. Secrets are synced to a Kubernetes Secret and mounted as environment variables.

Parameter Store path format: `/<appName>/<envSuffix>/<remoteKey>`

Example: `/stats-backend/dev/backend-password`

## Health Checks

The chart configures both liveness and readiness probes:

- **Liveness Probe**: Checks if the application is running
  - Path: `/`
  - Initial delay: 30 seconds
  - Period: 10 seconds

- **Readiness Probe**: Checks if the application is ready to receive traffic
  - Path: `/`
  - Initial delay: 10 seconds
  - Period: 5 seconds

## Troubleshooting

Replace `<namespace>` with your target namespace (e.g., `stats-backend-dev`, `stats-backend-prod`).

### Check Pod Status

```bash
kubectl get pods -n <namespace> -l app.kubernetes.io/name=stats-backend
kubectl describe pod -n <namespace> <pod-name>
kubectl logs -n <namespace> <pod-name>
```

### Check Service and Endpoints

```bash
kubectl get svc -n <namespace>
kubectl get endpoints -n <namespace>
```

### Check TargetGroupBinding

```bash
kubectl get targetgroupbindings -n <namespace>
kubectl describe targetgroupbinding -n <namespace> stats-backend
```

### Check External Secrets

```bash
kubectl get externalsecrets -n <namespace>
kubectl describe externalsecret -n <namespace> stats-backend-secrets
kubectl get secret -n <namespace> stats-backend-secrets
```

### Validate Chart

```bash
helm lint .
helm template stats-backend . -f values.yaml
```

## Development

### Testing Changes Locally

```bash
# Dry run to see what would be deployed
helm install stats-backend . -f values.yaml -f values-dev.yaml --dry-run --debug

# Template rendering
helm template stats-backend . -f values.yaml -f values-dev.yaml
```

### Linting

```bash
helm lint .
```
