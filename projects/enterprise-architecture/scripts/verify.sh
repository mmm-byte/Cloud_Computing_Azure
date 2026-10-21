#!/bin/bash
# Deployment Verification Script

set -e

ENVIRONMENT="${1:-prod}"
RESOURCE_GROUP="${ENVIRONMENT}-rg-app-001"

echo "Verifying deployment in $ENVIRONMENT..."

# Check resource group
echo "✓ Checking resource group: $RESOURCE_GROUP"
az group show --name "$RESOURCE_GROUP" --query "{name:name, location:location}" -o table

# Check app service
echo "✓ Checking App Service"
az webapp list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, state:state}" -o table

# Check SQL database
echo "✓ Checking SQL Database"
az sql db list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, maxSizeBytes:maxSizeBytes}" -o table

# Check storage account
echo "✓ Checking Storage Account"
az storage account list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, kind:kind}" -o table

# Check network resources
echo "✓ Checking Virtual Networks"
az network vnet list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, addressPrefix:addressSpace.addressPrefixes[0]}" -o table

echo "✓ Deployment verification completed successfully"
