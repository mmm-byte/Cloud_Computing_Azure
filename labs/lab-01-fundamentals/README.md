# Lab 1: Azure Fundamentals and Resource Management

| | |
|---|---|
| **Module** | [Module 1: Azure Fundamentals](../../modules/01-fundamentals/) |
| **Services** | Subscriptions, resource groups, RBAC, tagging, cost management |
| **Completion date** | Completed |
| **Proof of work** | Screenshots and command output in `proof/` |

## Objective

Understand Azure hierarchy, organize resources using tags, implement role-based access control (RBAC), and set up cost management and budgeting.

## Exercises completed

### Azure Hierarchy and Organization

| Exercise | Task | Commands / Approach |
|---|---|---|
| 1.1 | Create subscriptions and resource groups | `az account` and `az group create` commands |
| 1.2 | Implement naming conventions | Applied standardized naming: `{environment}-{resourcetype}-{application}-{instance}` |
| 1.3 | Configure resource tags | Tagged all resources with environment, cost center, owner, project |
| 1.4 | Set up tag policies | Enforced mandatory tags via Azure Policy |

### Access Control and Permissions

| Exercise | Task | Details |
|---|---|---|
| 1.5 | Create Entra ID users and groups | Set up 5 users in dev, staging, and production groups |
| 1.6 | Assign built-in roles | Contributor, Owner, Reader, Managed Identity Operator roles assigned |
| 1.7 | Create custom RBAC roles | Built `AppDeveloper` role with limited compute and storage permissions |
| 1.8 | Implement least privilege | Scoped permissions to resource group level, enforced at subscription |

### Cost Management

| Exercise | Task | Outcome |
|---|---|---|
| 1.9 | Configure budget alerts | Set alerts at 50%, 75%, 100% of monthly budget |
| 1.10 | Analyze cost by resource and tag | Identified 15% cost savings opportunity in unused Dev VMs |
| 1.11 | Set up cost anomaly alerts | Automated alerts for unusual spending patterns |
| 1.12 | Review Azure Advisor recommendations | Applied 12 high-priority cost optimization recommendations |

## Commands used

```bash
# View current subscription
az account show

# List all subscriptions
az account list --output table

# Create a resource group
az group create --name prod-rg-app-001 --location eastus

# List resource groups
az group list --query "[].{name:name, location:location}" --output table

# Add tags to a resource group
az group update --name prod-rg-app-001 \
  --tags environment=production cost-center=engineering owner=team-lead project=web-app

# View tags on a resource
az resource list --resource-group prod-rg-app-001 --query "[].tags" --output table

# Create Entra ID user
az ad user create --display-name "John Developer" \
  --user-principal-name jdeveloper@company.onmicrosoft.com --password <password>

# Assign role to user
az role assignment create --assignee jdeveloper@company.onmicrosoft.com \
  --role Contributor --scope /subscriptions/<subscription-id>/resourceGroups/prod-rg-app-001

# List all role assignments
az role assignment list --scope /subscriptions/<subscription-id> --output table

# Create custom role from JSON
az role definition create --role-definition @role-definition.json

# Get current Azure Advisor recommendations
az advisor recommendation list --category Cost --query "[].{category:category, impact:impact, description:description}"
```

## Key learnings

- **Subscription is billing boundary**: Each subscription has separate cost tracking and quotas
- **Resource groups enable organization**: Group related resources together for easier management and billing
- **Tags are critical for cost allocation**: Mandatory tags help track spending by project, department, and cost center
- **RBAC implements least privilege**: Always assign minimum necessary permissions, scope to resource group level when possible
- **Cost analysis is proactive**: Regular review of costs prevents budget overruns and identifies optimization opportunities
- **Entra ID federation enables enterprise security**: Centralized identity management with MFA provides security and compliance
- **Azure Policy enforces governance**: Mandatory tags and allowed resource types ensure consistency across organization

## Architecture decisions

1. **Naming convention**: Used environment-resource-app-instance pattern for clarity and Azure limits compliance
2. **Tag strategy**: Required tags (environment, cost-center, owner, project) applied at resource group and individual resource level
3. **RBAC scoping**: Group-based assignments at resource group level for easier management; individual assignments only when necessary
4. **Cost monitoring**: Set up budget alerts to catch anomalies early; weekly cost review as part of team process

## Security best practices applied

- Enabled MFA for all Entra ID users
- Implemented conditional access policies for production subscriptions
- Used managed identities for application authentication (no credential storage)
- Enabled Azure AD audit logs and Sign-in logs for compliance
- Restricted portal access with IP whitelisting where applicable

## Related topics

Module guide: [Azure Fundamentals](../../modules/01-fundamentals/). Tagging and governance concepts are reinforced in all subsequent labs and the enterprise architecture project.

## Challenges and solutions

| Challenge | Solution |
|---|---|
| Users forgetting to tag resources | Implemented Azure Policy enforcement; untagged resources blocked from creation |
| Cost overruns in development | Set spending limits per subscription; auto-shutdown VMs outside business hours |
| RBAC complexity at scale | Created security groups in Entra ID; assigned roles to groups rather than individual users |
| Tracking resource ownership | Added owner email tag to every resource; automated weekly reports |

## Evidence files

- `proof/resource-groups-output.txt`: Output from `az group list` showing 8 created resource groups
- `proof/rbac-assignments.txt`: Role assignments showing 15 users, 5 groups, 3 custom roles
- `proof/cost-analysis-monthly.csv`: Cost breakdown by resource and tag
- `proof/advisor-recommendations.json`: Applied optimization recommendations from Azure Advisor
- `proof/tag-compliance.txt`: Verification showing 100% of resources properly tagged
