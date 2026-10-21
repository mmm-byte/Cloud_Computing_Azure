# Deployment Guide

## Quick Start

### Prerequisites

1. **Install tools**:
   - Terraform 1.0+
   - Azure CLI 2.40+
   - jq (JSON processor)
   - Git

2. **Azure authentication**:
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

3. **Prepare secrets**:
   - SQL admin password (min 12 chars, uppercase, number, special char)
   - Email for alerts

### Deployment Steps

1. **Clone and navigate to project**:
   ```bash
   cd projects/enterprise-architecture
   ```

2. **Review deployment plan**:
   ```bash
   ./scripts/deploy.sh prod plan
   ```

3. **Apply infrastructure** (requires approval for prod):
   ```bash
   ./scripts/deploy.sh prod apply
   ```

4. **Verify deployment**:
   ```bash
   ./scripts/verify.sh prod
   ```

5. **Set up monitoring**:
   ```bash
   ./scripts/setup-monitoring.sh prod ops@company.com
   ```

## Environment Configuration

Each environment (dev, staging, prod) has specific settings in `terraform/env/*.tfvars`:

- **Dev**: B1 App Service, Basic SQL, LRS Storage
- **Staging**: S1 App Service, Standard SQL, GRS Storage
- **Prod**: S2 App Service, Premium SQL, GZRS Storage

Customize these files before deployment.

## State Management

Terraform state is stored in Azure Storage:

- Resource Group: `terraform-state-rg`
- Storage Account: `tfstate001`
- Container: `tfstate`

First-time setup requires creating this storage account.

## Troubleshooting

### Authentication Error
```bash
az logout
az login
az account set --subscription <subscription-id>
```

### Terraform Lock
If deployment hangs on lock:
```bash
cd terraform
terraform force-unlock <lock-id>
```

### Rollback
```bash
./scripts/rollback.sh prod
```

## Documentation

- **ARCHITECTURE.md**: Complete architecture design
- **DISASTER_RECOVERY.md**: Recovery procedures
- **DEPLOYMENT_CHECKLIST.md**: Pre/post deployment verification

## Support

For issues:
1. Check logs: `tail -f logs/deployment-*.log`
2. Review Terraform plan: `terraform plan -var-file=env/prod.tfvars`
3. Check Azure Portal for resource creation errors
