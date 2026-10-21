#!/bin/bash
# Rollback infrastructure to previous state

set -e

ENVIRONMENT="${1:-prod}"
TERRAFORM_DIR="./terraform"

echo "Rolling back infrastructure in $ENVIRONMENT environment..."

cd "$TERRAFORM_DIR"

# Show current state
echo "Current resources:"
terraform state list

# Remove recent changes
read -p "Enter resource address to rollback (or 'cancel'): " resource_address

if [ "$resource_address" != "cancel" ]; then
  terraform state rm "$resource_address"
  echo "✓ Rolled back: $resource_address"
else
  echo "Rollback cancelled"
fi
