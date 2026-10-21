# Disaster Recovery Runbook

## Overview

This document outlines procedures for recovering from various failure scenarios in the Azure infrastructure.

## Failure Scenarios

### Scenario 1: Primary Database Failover

**Symptoms**: Application cannot connect to primary SQL database

**Detection**: Application logs show connection timeout

**Recovery Steps**:

1. **Verify failure** (0-1 min)
   ```bash
   az sql failover-group show \
     --resource-group prod-rg-data-001 \
     --server prod-sql-001 \
     --name prod-failover-001 \
     --query "replicationRole"
   ```

2. **Initiate failover** (1-2 min)
   ```bash
   az sql failover-group set-primary \
     --resource-group prod-rg-data-001 \
     --server prod-sql-replica-001 \
     --name prod-failover-001
   ```

3. **Verify new primary** (2-3 min)
   - Check application logs for successful reconnection
   - Monitor SQL Server connection count
   - Confirm read replicas are replicating

4. **Post-failover** (3-10 min)
   - Update connection strings if needed
   - Verify data consistency
   - Document incident in ticket system

**RTO**: 5 minutes
**RPO**: 0 minutes (synchronous replication)

### Scenario 2: App Service Failure

**Symptoms**: Application returns 500 errors or is unreachable

**Detection**: Application Gateway health check fails

**Recovery Steps**:

1. **Check instance status** (0-1 min)
   ```bash
   az webapp list --resource-group prod-rg-app-001 \
     --query "[].{name:name, state:state}" -o table
   ```

2. **Restart affected instance** (1-2 min)
   ```bash
   az webapp restart --resource-group prod-rg-app-001 \
     --name prod-web-app-001
   ```

3. **Monitor recovery** (2-5 min)
   - Check Application Insights for error rates
   - Monitor response times
   - Verify traffic is balanced across instances

4. **Manual fix if restart fails** (5-15 min)
   - Check Application logs
   - Review recent deployments
   - Perform blue-green swap if needed

**RTO**: 5 minutes
**RPO**: No data loss

### Scenario 3: Storage Account Inaccessibility

**Symptoms**: File shares unavailable or blob access fails

**Detection**: Storage API returns 503 Service Unavailable

**Recovery Steps**:

1. **Check service status** (0-1 min)
   ```bash
   az storage account show --name prodstgapp001 \
     --resource-group prod-rg-data-001 \
     --query "statusOfPrimary"
   ```

2. **Wait for failover** (1-5 min)
   - Storage account automatically fails over to secondary region
   - No manual action required for geo-redundant storage

3. **Verify read access** (5-10 min)
   ```bash
   az storage blob list --account-name prodstgapp001 \
     --container-name app-data
   ```

4. **Restore if needed** (10-30 min)
   - If data is lost, restore from backup snapshot
   - Validate data integrity

**RTO**: 5 minutes (automatic)
**RPO**: 1 minute

## Backup and Restore Procedures

### Database Restore

```bash
# List available restore points
az sql db list-restore-points \
  --resource-group prod-rg-data-001 \
  --server prod-sql-001 \
  --database prod-db-app-001

# Restore to point-in-time
az sql db restore \
  --dest-name prod-db-app-001-restore \
  --dest-resource-group prod-rg-data-001 \
  --name prod-db-app-001 \
  --resource-group prod-rg-data-001 \
  --server prod-sql-001 \
  --point-in-time 2024-10-20T10:30:00Z

# Verify restored database
az sql db show \
  --resource-group prod-rg-data-001 \
  --server prod-sql-001 \
  --name prod-db-app-001-restore
```

### File Restore

```bash
# List blob snapshots
az storage blob list-snapshots \
  --account-name prodstgapp001 \
  --container-name app-data

# Restore from snapshot
az storage blob snapshot \
  --account-name prodstgapp001 \
  --container-name app-data \
  --name important-file.txt
```

## Post-Recovery Actions

1. **Verify data integrity**: Run database consistency checks
2. **Test application**: Confirm application connects and functions
3. **Monitor metrics**: Ensure performance is acceptable
4. **Document incident**: Create post-mortem with root cause
5. **Improve prevention**: Implement changes to prevent recurrence

## Testing and Drills

### Monthly Test: Database Failover

- Initiate planned failover to secondary
- Measure RTO and RPO
- Verify application behavior
- Document findings

### Monthly Test: Backup Restore

- Restore recent backup to test environment
- Validate data integrity
- Confirm restoration speed
- Update runbook if needed

## Key Contacts

- **On-Call Engineer**: +1-555-0123
- **Infrastructure Lead**: infrastructure-lead@company.com
- **Database Team**: database-team@company.com
- **Security Team**: security@company.com

## References

- Azure SQL Database Backup: https://learn.microsoft.com/azure/azure-sql/database/backup-overview
- Storage Account Failover: https://learn.microsoft.com/azure/storage/common/storage-disaster-recovery-guidance
- Application Gateway Health Probes: https://learn.microsoft.com/azure/application-gateway/application-gateway-probe-info
