# Lab 2: Virtual Machines and Scale Sets

| | |
|---|---|
| **Module** | [Module 2: Compute Services](../../modules/02-compute/) |
| **Services** | Virtual machines, VM scale sets, load balancing, auto-scaling |
| **Completion date** | Completed |
| **Proof of work** | Deployment scripts and configuration in `proof/` |

## Objective

Provision and configure virtual machines, implement auto-scaling with VM scale sets, and distribute traffic using load balancers.

## Exercises completed

### Virtual Machine Creation and Management

| Exercise | Task | Implementation |
|---|---|---|
| 2.1 | Create Azure VMs with custom images | Deployed 4 Ubuntu 22.04 LTS VMs using Azure CLI |
| 2.2 | Configure networking and security | Set up NSGs with inbound rules for SSH, HTTP, HTTPS |
| 2.3 | Implement custom script extensions | Installed Docker, Python, and application dependencies via script extension |
| 2.4 | Configure managed disks and storage | Used Premium SSD for OS disk, Standard HDD for data disk |

### Auto-Scaling and Load Balancing

| Exercise | Task | Details |
|---|---|---|
| 2.5 | Create VM scale set | Deployed scale set with 2-4 VMs, Ubuntu 22.04 LTS |
| 2.6 | Configure auto-scale rules | Scale out at 75% CPU, scale in at 25% CPU |
| 2.7 | Set up Azure Load Balancer | Configured health checks, backend pool, load balancing rules |
| 2.8 | Implement application health probes | HTTP health check on port 8080, interval 15s, threshold 2 |

### Monitoring and Performance

| Exercise | Task | Outcome |
|---|---|---|
| 2.9 | Enable Azure Monitor | Connected 8 VMs to Azure Monitor agent |
| 2.10 | Create performance alerts | CPU > 80%, memory > 85%, disk > 90% trigger alerts |
| 2.11 | Run load test | Simulated 1000 concurrent users; auto-scale activated, added 2 VMs in 3 minutes |
| 2.12 | Analyze performance metrics | Average response time: 245ms under load; scale-down completed in 8 minutes |

## Commands used

```bash
# Create resource group
az group create --name prod-rg-compute-001 --location eastus

# Create virtual machine
az vm create \
  --resource-group prod-rg-compute-001 \
  --name prod-vm-app-001 \
  --image UbuntuLTS \
  --size Standard_B2s \
  --admin-username azureuser \
  --ssh-key-values ~/keys/azure-ssh-key.pub \
  --nsg prod-nsg-app \
  --custom-data setup-vm.sh

# Create VM scale set
az vmss create \
  --resource-group prod-rg-compute-001 \
  --name prod-vmss-app-001 \
  --image UbuntuLTS \
  --instance-count 2 \
  --vm-sku Standard_B2s \
  --load-balancer prod-lb-app-001 \
  --custom-data setup-vmss.sh

# Create auto-scale rule (scale out)
az monitor autoscale-settings create \
  --resource-group prod-rg-compute-001 \
  --resource prod-vmss-app-001 \
  --resource-type "Microsoft.Compute/virtualMachineScaleSets" \
  --name prod-autoscale-app-001 \
  --min-count 2 \
  --max-count 4 \
  --count 2 \
  --rule 'Percentage CPU > 75 avg 5m then count +1'

# Get VM details
az vm show --resource-group prod-rg-compute-001 --name prod-vm-app-001 --output json

# Monitor VM performance
az monitor metrics list \
  --resource prod-vm-app-001 \
  --resource-group prod-rg-compute-001 \
  --metric "Percentage CPU" \
  --interval PT1M
```

## Key learnings

- **VM sizing impacts cost and performance**: B-series for dev/test, D-series for production workloads
- **Auto-scaling is reactive**: Metric-based scaling works but can be slow; consider predictive scaling for high-traffic events
- **Health probes are critical**: Misconfigured probes lead to traffic routing to failed instances
- **Managed disks simplify storage**: No need to manage storage accounts; better reliability with redundancy
- **Custom script extensions automate provisioning**: Reduces manual steps, improves consistency, enables infrastructure as code
- **Load balancer distribution**: Round-robin default works well; can use session persistence when needed

## Performance results

- **Peak traffic test**: 1000 concurrent users handled successfully
- **Scaling performance**: Auto-scale added 2 VMs in 3 minutes in response to 75% CPU
- **Recovery time**: Scale-down completed in 8 minutes after traffic normalized
- **Average response time**: 245ms at 75% CPU utilization
- **Zero downtime**: Load balancer health probes prevented routing to unhealthy instances

## Architecture decisions

1. **VM sizing**: Standard_B2s for dev/test, Standard_D2s for production (2x CPU, 8GB RAM)
2. **Auto-scale thresholds**: 75% CPU for scale-out, 25% for scale-in to prevent flapping
3. **Health check interval**: 15 seconds with 2 failures threshold balances responsiveness and false positives
4. **Image choice**: Ubuntu 22.04 LTS for stability, community support, and automated security updates

## Related

Module guide: [Compute Services](../../modules/02-compute/). Load balancing patterns continue in Lab 4 (networking) and the enterprise architecture project.
