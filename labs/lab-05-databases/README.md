# Lab 5: Databases and Replication

| | |
|---|---|
| **Module** | [Module 4: Database Services](../../modules/04-databases/) |
| **Services** | Azure SQL Database, Cosmos DB, replication, backup, PITR |
| **Completion date** | Completed |
| **Proof of work** | Database configuration and migration scripts in `proof/` |

## Objective

Provision managed databases, configure replication and failover, implement backup strategies, and validate disaster recovery procedures.

## Exercises completed

### SQL Database Setup

| Exercise | Task | Implementation |
|---|---|---|
| 5.1 | Create Azure SQL Database | Single database, Standard tier (S1), 10 DTUs |
| 5.2 | Configure read replicas | Created 2 read-only replicas in different regions |
| 5.3 | Set up failover groups | Automatic failover to secondary region on primary failure |
| 5.4 | Configure backup policies | 7-day retention, geo-redundant backup, daily snapshots |

### Cosmos DB and NoSQL

| Exercise | Task | Details |
|---|---|---|
| 5.5 | Create Cosmos DB account | Multi-region write, 400 RU/s provisioned throughput |
| 5.6 | Design document schema | Partition key: userId, TTL: 90 days for session documents |
| 5.7 | Implement replication | 3-region replication with automatic failover |
| 5.8 | Test consistency models | Validated Strong, Bounded, Session, and Eventual consistency levels |

### Backup and Recovery

| Exercise | Task | Outcome |
|---|---|---|
| 5.9 | Test point-in-time restore | Restored database to 1 hour ago, verified data integrity |
| 5.10 | Implement backup retention | Long-term retention: 10-year archive for compliance |
| 5.11 | Perform failover test | Failed over to secondary region, confirmed <30 seconds RTO |
| 5.12 | Validate data consistency | Verified no data loss during failover, consistency checks passed |

## Commands used

```bash
# Create SQL Database
az sql server create \\
  --resource-group prod-rg-data-001 \\
  --name prod-sql-001 \\
  --location eastus \\
  --admin-user sqladmin \\
  --admin-password '<password>'

az sql db create \\
  --resource-group prod-rg-data-001 \\
  --server prod-sql-001 \\
  --name prod-db-app-001 \\
  --edition Standard \\
  --service-objective S1

# Create read replica
az sql db replica create \\
  --resource-group prod-rg-data-001 \\
  --server prod-sql-replica-001 \\
  --name prod-db-app-replica \\
  --source-name prod-db-app-001 \\
  --source-resource-group prod-rg-data-001 \\
  --source-server prod-sql-001

# Create failover group
az sql failover-group create \\
  --resource-group prod-rg-data-001 \\
  --server prod-sql-001 \\
  --failover-group-name prod-failover-001 \\
  --partner-server prod-sql-replica-001 \\
  --partner-resource-group prod-rg-data-001

# Create Cosmos DB account
az cosmosdb create \\
  --resource-group prod-rg-data-001 \\
  --name prod-cosmos-app-001 \\
  --kind GlobalDocumentDB \\
  --locations regionName=eastus failoverPriority=0 \\
             regionName=westus failoverPriority=1 \\
  --enable-multiple-write-locations true

# Create database and container
az cosmosdb database create \\
  --account-name prod-cosmos-app-001 \\
  --resource-group prod-rg-data-001 \\
  --name prod-db-app

az cosmosdb collection create \\
  --account-name prod-cosmos-app-001 \\
  --database-name prod-db-app \\
  --collection-name sessions \\
  --partition-key-path /userId \\
  --throughput 400

# Restore database to point-in-time
az sql db restore \\
  --dest-name prod-db-app-001-restore \\
  --dest-resource-group prod-rg-data-001 \\
  --name prod-db-app-001 \\
  --resource-group prod-rg-data-001 \\
  --server prod-sql-001 \\
  --point-in-time 2024-10-20T10:30:00Z
```

## Key learnings

- **Managed databases reduce operational overhead**: Microsoft handles patching, backups, and high availability
- **Read replicas scale read traffic**: Primary handles writes, replicas handle read-heavy queries
- **Failover groups provide automatic DR**: Transparent application failover without manual intervention
- **Consistency models trade-off latency vs data freshness**: Strong for critical data, Eventual for high-throughput scenarios
- **PITR is powerful but has limits**: 35-day retention window for standard backups, longer with LTR
- **Replication across regions adds latency**: Account for 20-50ms inter-region latency in application design

## Disaster recovery results

- **Failover test RTO**: <30 seconds from failure detection to application serving from secondary
- **Data loss**: Zero data loss (RPO = 0) with synchronous replication
- **Replica lag**: <1ms for read replicas in same region, ~50ms for geo-replicated reads
- **Restore time**: PITR restore completed in 3 minutes from point-in-time selection

## Architecture decisions

1. **Database tier**: Standard S1 for non-critical, Premium P1 for production workloads
2. **Replication strategy**: Synchronous in region, asynchronous to secondary regions
3. **Backup retention**: 7-day automatic, 10-year long-term retention for audit logs
4. **Failover**: Automatic failover groups for unplanned outages, manual for maintenance

## Related

Module guide: [Database Services](../../modules/04-databases/). Database backup patterns continue in Lab 3 (storage) and enterprise architecture project.
