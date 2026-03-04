# stats-backend Helm Chart

A Helm chart for deploying the RSK Network Stats Backend application on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- AWS Load Balancer Controller (if using ALB ingress or TargetGroupBinding)
- External Secrets Operator (if using ExternalSecrets)

## Installation

### Basic Installation

```bash
# Create namespace first
kubectl create namespace stats-backend

# Install with default values
helm install stats-backend ./helm -n stats-backend
```

### Environment-Specific Installation

```bash
# Development
kubectl create namespace stats-backend-dev
helm install stats-backend ./helm -n stats-backend-dev -f helm/values-dev.yaml

# Production
kubectl create namespace stats-backend-prod
helm install stats-backend ./helm -n stats-backend-prod -f helm/values-prod.yaml
```

### Upgrade

```bash
helm upgrade stats-backend ./helm -n stats-backend -f helm/values.yaml
```

### Uninstall

```bash
helm uninstall stats-backend -n stats-backend
```

## Configuration

### Core Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of pod replicas | `2` |
| `namespace` | Target namespace for deployment | `stats-backend` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full chart name | `""` |

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `654654249872.dkr.ecr.us-east-2.amazonaws.com/stats-backend` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `image.tag` | Image tag | `latest` |

### Environment Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env.nodeEnv` | Node environment (development, production) | `production` |

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `NodePort` |
| `service.port` | Service port | `3000` |
| `service.targetPort` | Container port | `3000` |

### Ingress Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress resource | `false` |
| `ingress.className` | Ingress class name | `alb` |
| `ingress.groupName` | ALB group name for sharing | `""` |
| `ingress.groupOrder` | Rule evaluation order | `100` |
| `ingress.certificateArn` | ACM certificate ARN for HTTPS | `""` |
| `ingress.annotations` | Additional annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |

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
| `externalSecrets.parameterPaths.wsSecret` | Parameter Store path for WS secret | `/stats-backend/ws-secret` |

## Load Balancer Options

This chart supports two methods for exposing the application via AWS ALB:

### Option 1: Kubernetes-Managed ALB (Ingress)

Use this when you want the AWS Load Balancer Controller to create and manage the ALB.

```yaml
ingress:
  enabled: true
  className: alb
  certificateArn: "arn:aws:acm:region:account:certificate/xxx"
  hosts:
    - host: stats-backend.example.com
      paths:
        - path: /
          pathType: Prefix
```

**Sharing an ALB with other services:**

```yaml
ingress:
  enabled: true
  groupName: "shared-alb"
  groupOrder: 100
```

### Option 2: External ALB (TargetGroupBinding)

Use this when the ALB is created externally (e.g., by Terraform) and you just need to register the service with an existing target group.

```yaml
ingress:
  enabled: false

targetGroupBinding:
  enabled: true
  targetGroupArn: "arn:aws:elasticloadbalancing:region:account:targetgroup/name/xxx"
  targetType: instance
```

## External Secrets

This chart integrates with the External Secrets Operator to sync secrets from AWS Parameter Store.

### Prerequisites

1. External Secrets Operator installed in the cluster
2. A `ClusterSecretStore` named `aws-parameter-store` configured

### Enabling External Secrets

```yaml
externalSecrets:
  enabled: true
  parameterPaths:
    wsSecret: /stats-backend/prod/ws-secret
```

The secret will be mounted as the `WS_SECRET` environment variable in the container.

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

### Check Pod Status

```bash
kubectl get pods -n stats-backend -l app.kubernetes.io/name=stats-backend
kubectl describe pod -n stats-backend <pod-name>
kubectl logs -n stats-backend <pod-name>
```

### Check Service and Endpoints

```bash
kubectl get svc -n stats-backend
kubectl get endpoints -n stats-backend
```

### Check Ingress or TargetGroupBinding

```bash
# For Ingress
kubectl get ingress -n stats-backend
kubectl describe ingress -n stats-backend stats-backend

# For TargetGroupBinding
kubectl get targetgroupbindings -n stats-backend
kubectl describe targetgroupbinding -n stats-backend stats-backend
```

### Validate Chart

```bash
helm lint ./helm
helm template stats-backend ./helm -f helm/values.yaml
```

## Development

### Testing Changes Locally

```bash
# Dry run to see what would be deployed
helm install stats-backend ./helm --dry-run --debug

# Template rendering
helm template stats-backend ./helm -f helm/values-dev.yaml
```

### Linting

```bash
helm lint ./helm
```
