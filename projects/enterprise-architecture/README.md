# Enterprise Azure Architecture

Infrastructure as Code implementation of a multi-tier, production-ready Azure architecture.

## Overview

This project demonstrates enterprise-scale cloud architecture patterns using Terraform. It provisions a complete infrastructure spanning compute, networking, storage, and databases across Azure.

## Architecture

```
Internet Traffic
    ↓
Application Gateway (WAF enabled)
    ↓
Load Balancer
    ├─→ Web Tier: App Service instances (auto-scale)
    ├─→ API Tier: Container instances
    └─→ Background Jobs: Batch processing
    ↓
VNet with NSGs
    ├─→ Database Subnet: Azure SQL Database (read replicas)
    ├─→ Cache Subnet: Azure Cache for Redis
    └─→ Storage Subnet: Blob Storage (geo-replicated)

Monitoring: Azure Monitor, Application Insights
DevOps: Azure Pipelines for continuous deployment
```

## Layout

| Path | Purpose |
|---|---|
| `terraform/` | Infrastructure as Code modules for compute, networking, storage, databases |
| `scripts/` | Deployment automation scripts |
| `documentation/` | Architecture decisions, runbooks, disaster recovery procedures |

## Components

### Infrastructure Modules

- **Compute**: App Service, scale sets, container instances
- **Networking**: VNets, subnets, NSGs, load balancers, Application Gateway
- **Storage**: Storage accounts with geo-replication, managed disks
- **Databases**: SQL Database with read replicas, Cosmos DB, Redis cache

### Deployment Automation

- Azure Pipelines for CI/CD
- Terraform state management
- Automated testing and validation
- Blue-green deployment strategy

## Deployment

```bash
# Initialize Terraform
terraform init

# Plan infrastructure changes
terraform plan -var-file=env/prod.tfvars

# Apply configuration
terraform apply -var-file=env/prod.tfvars

# Verify deployment
scripts/verify_deployment.sh
```

## Configuration

Key variables:

- `environment`: dev, staging, production
- `location`: Azure region for primary deployment
- `replica_location`: Azure region for geo-replication
- `vm_count`: Number of application instances
- `db_sku`: Database performance tier

## Monitoring and Alerts

- Application Insights for application telemetry
- Azure Monitor for infrastructure metrics
- Alert rules for critical thresholds
- Custom dashboards for operations team

## Disaster Recovery

- Geo-replicated storage and databases
- Automated failover for high-availability services
- Recovery procedures documented in `documentation/`
- Regular DR drills and RTO/RPO validation

## Known Gaps and Future Work

- [ ] Implement Azure Front Door for global load balancing
- [ ] Add Network Watcher flow logs for security analysis
- [ ] Implement Azure Bastion for secure VM access
- [ ] Add API Management for rate limiting and versioning
- [ ] Integrate with Azure DevSecOps for security scanning

## Related Coursework

[Module 2: Compute Services](../../modules/02-compute/), [Module 5: Networking](../../modules/05-networking/), [Module 6: DevOps and Automation](../../modules/06-devops/)
