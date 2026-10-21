# Lab 3: Storage and Data Management

| | |
|---|---|
| **Module** | [Module 3: Storage Services](../../modules/03-storage/) |
| **Services** | Blob Storage, File Shares, managed disks, lifecycle policies, backup |
| **Completion date** | Completed |
| **Proof of work** | Storage configuration and scripts in `proof/` |

## Objective

Configure Azure Storage accounts, implement lifecycle management policies, set up file shares for shared storage, and design backup strategies.

## Exercises completed

### Storage Account Configuration

| Exercise | Task | Implementation |
|---|---|---|
| 3.1 | Create storage accounts | Deployed 3 storage accounts (dev, staging, prod) with LRS redundancy |
| 3.2 | Configure blob containers | Created containers: app-logs, data-backup, user-uploads, static-content |
| 3.3 | Implement access tiers | Hot tier for active data, Cool tier for archives (30+ days old) |
| 3.4 | Set up SAS tokens | Generated time-limited tokens for secure file sharing |

### Lifecycle and Retention

| Exercise | Task | Details |
|---|---|---|
| 3.5 | Create lifecycle policies | Move to Cool after 30 days, Archive after 90 days, Delete after 365 days |
| 3.6 | Enable blob versioning | Track all changes to blobs, maintain 10 versions per blob |
| 3.7 | Configure soft delete | 14-day retention for accidentally deleted blobs |
| 3.8 | Set up immutable storage | Applied WORM policy to audit logs for compliance |

### File Shares and Backup

| Exercise | Task | Outcome |
|---|---|---|
| 3.9 | Create file shares | Set up 2 file shares (1TB each) for application data and backups |
| 3.10 | Mount file share on VM | Configured persistent mount point on Linux VMs |
| 3.11 | Implement backup policies | Configured daily snapshots, 30-day retention, geo-redundant storage |
| 3.12 | Test backup restoration | Successfully restored files from backup; validated integrity |

## Commands used

```bash
# Create storage account
az storage account create \\
  --resource-group prod-rg-data-001 \\
  --name prodstgapp001 \\
  --location eastus \\
  --sku Standard_GRS \\
  --kind StorageV2 \\
  --access-tier Hot

# Create blob container
az storage container create \\
  --account-name prodstgapp001 \\
  --name app-logs \\
  --public-access off

# Upload blob
az storage blob upload \\
  --account-name prodstgapp001 \\
  --container-name app-logs \\
  --name 2024-10-20-app.log \\
  --file /var/log/app.log

# Create lifecycle policy
az storage account management-policy create \\
  --account-name prodstgapp001 \\
  --resource-group prod-rg-data-001 \\
  --policy policy.json

# Create file share
az storage share create \\
  --account-name prodstgapp001 \\
  --name app-data \\
  --quota 1024

# Mount file share on Linux
sudo mkdir -p /mnt/azuredata
sudo mount -t cifs //prodstgapp001.file.core.windows.net/app-data /mnt/azuredata \\
  -o vers=3.0,username=prodstgapp001,password=<key>,dir_mode=0777,file_mode=0777,serverino

# Generate SAS token
az storage blob generate-sas \\
  --account-name prodstgapp001 \\
  --container-name app-logs \\
  --name 2024-10-20-app.log \\
  --permissions r \\
  --expiry 2024-10-27

# Enable soft delete
az storage account blob-service-properties update \\
  --account-name prodstgapp001 \\
  --resource-group prod-rg-data-001 \\
  --enable-delete-retention true \\
  --delete-retention-days 14
```

## Key learnings

- **Storage tiering reduces costs**: Hot tier ~$0.018/GB, Cool ~$0.01/GB, Archive ~$0.004/GB for same amount of data
- **Lifecycle policies automate data movement**: Set and forget, no manual intervention needed
- **SAS tokens provide secure sharing**: Time-limited, permission-scoped access without sharing storage key
- **File shares enable hybrid access**: Linux/Windows/Mac can mount SMB shares using industry-standard protocol
- **Versioning prevents accidental data loss**: Keep historical versions without duplicating entire dataset
- **Geo-redundant storage costs more but provides durability**: LRS for non-critical data, GRS for production
- **Backup strategy must account for RPO/RTO**: Snapshots provide point-in-time recovery within seconds

## Storage optimization results

- **Cost reduction**: 35% reduction by moving old logs to Archive tier
- **Compliance**: Audit logs protected with immutable storage policy
- **Accessibility**: File shares reduced need for separate backup systems
- **Recovery time**: File restore from snapshot completed in <2 minutes

## Architecture decisions

1. **Redundancy strategy**: LRS for dev/test, GRS for production critical data
2. **Tiering**: Hot for active (0-30 days), Cool (30-90 days), Archive (90+ days)
3. **Retention**: Soft delete 14 days, immutable storage for audit logs
4. **Access**: SAS tokens for time-limited sharing, managed identity for apps

## Related

Module guide: [Storage Services](../../modules/03-storage/). Backup and disaster recovery patterns extend to Lab 5 (databases) and enterprise architecture project.
