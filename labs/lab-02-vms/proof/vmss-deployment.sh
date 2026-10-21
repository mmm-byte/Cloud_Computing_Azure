#!/bin/bash
# VM Scale Set Deployment Script
set -e

RESOURCE_GROUP="prod-rg-compute-001"
LOCATION="eastus"
VMSS_NAME="prod-vmss-app-001"
LB_NAME="prod-lb-app-001"
ENVIRONMENT="production"

echo "Creating VM Scale Set..."
az vmss create \
  --resource-group $RESOURCE_GROUP \
  --name $VMSS_NAME \
  --image UbuntuLTS \
  --instance-count 2 \
  --vm-sku Standard_B2s \
  --storage-sku Premium_LRS \
  --load-balancer $LB_NAME \
  --custom-data setup-vmss.sh \
  --tags environment=$ENVIRONMENT owner=devops

echo "Configuring auto-scale..."
az monitor autoscale-settings create \
  --resource-group $RESOURCE_GROUP \
  --resource $VMSS_NAME \
  --resource-type "Microsoft.Compute/virtualMachineScaleSets" \
  --name autoscale-$VMSS_NAME \
  --min-count 2 \
  --max-count 4 \
  --count 2 \
  --rule 'Percentage CPU > 75 avg 5m then count +1 max 1' \
  --rule 'Percentage CPU < 25 avg 10m then count -1 min 1'

echo "✓ VM Scale Set deployment completed"
