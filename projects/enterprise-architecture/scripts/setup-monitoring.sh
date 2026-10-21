#!/bin/bash
# Set up monitoring and alerts

set -e

ENVIRONMENT="${1:-prod}"
RESOURCE_GROUP="${ENVIRONMENT}-rg-app-001"
ALERT_EMAIL="${2:-security@company.com}"

echo "Setting up monitoring for $ENVIRONMENT environment..."

# Get resource IDs
APP_SERVICE=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[0].id" -o tsv)
SQL_SERVER=$(az sql server list --resource-group "$RESOURCE_GROUP" --query "[0].id" -o tsv)

# Create metric alert for App Service CPU
echo "Creating CPU usage alert..."
az monitor metrics alert create \
  --resource-group "$RESOURCE_GROUP" \
  --name "${ENVIRONMENT}-alert-cpu-high" \
  --scopes "$APP_SERVICE" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --actions email-action \
  --action-group-id "$(az monitor action-group list --resource-group "$RESOURCE_GROUP" --query "[0].id" -o tsv)" \
  --description "Alert when CPU usage exceeds 80%"

echo "✓ Monitoring setup completed"
