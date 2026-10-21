# Lab 6: App Service and Container Deployment

| | |
|---|---|
| **Module** | [Module 2: Compute Services](../../modules/02-compute/) |
| **Services** | App Service, Container Registry, deployment slots, CI/CD |
| **Completion date** | Completed |
| **Proof of work** | Deployment scripts and configuration in `proof/` |

## Objective

Deploy applications to Azure App Service, containerize applications, implement blue-green deployments, and set up continuous integration/delivery pipelines.

## Exercises completed

### App Service Deployment

| Exercise | Task | Implementation |
|---|---|---|
| 6.1 | Create App Service plan | Windows OS, Standard tier (S1), 3 instances for production |
| 6.2 | Deploy web applications | Deployed 2 .NET applications from GitHub using continuous deployment |
| 6.3 | Configure app settings | Environment variables, connection strings, app settings |
| 6.4 | Set up custom domains | Configured SSL/TLS certificate, enabled HTTPS-only traffic |

### Container and Registry

| Exercise | Task | Details |
|---|---|---|
| 6.5 | Create container registry | Pushed Docker images of web app and API to registry |
| 6.6 | Build container images | Multi-stage build for 50% smaller final image size |
| 6.7 | Publish to registry | Automated image tagging (latest, v1.2.3, commit-sha) |
| 6.8 | Set up image cleanup | Policy to delete untagged images older than 30 days |

### Deployment Strategies

| Exercise | Task | Outcome |
|---|---|---|
| 6.9 | Implement deployment slots | Blue (production) and Green (staging) slots with traffic split |
| 6.10 | Configure slot swapping | Validated green deployment before swapping to production |
| 6.11 | Set up traffic management | Gradual traffic shift: 10% → 25% → 50% → 100% |
| 6.12 | Implement automatic rollback | Monitor post-deployment, automatic rollback if errors spike |

## Commands used

```bash
# Create App Service plan
az appservice plan create \\
  --name prod-asp-app-001 \\
  --resource-group prod-rg-app-001 \\
  --sku S1 \\
  --is-linux

# Create web app
az webapp create \\
  --resource-group prod-rg-app-001 \\
  --plan prod-asp-app-001 \\
  --name prod-web-app-001

# Configure continuous deployment
az webapp deployment github-actions add \\
  --repo-url https://github.com/user/app-repo \\
  --name prod-web-app-001 \\
  --resource-group prod-rg-app-001

# Create container registry
az acr create \\
  --resource-group prod-rg-app-001 \\
  --name prodacrapp001 \\
  --sku Basic

# Build image in registry
az acr build \\
  --registry prodacrapp001 \\
  --image prod-app:latest \\
  --file Dockerfile .

# Deploy from container registry
az webapp config container set \\
  --resource-group prod-rg-app-001 \\
  --name prod-web-app-001 \\
  --docker-custom-image-name prodacrapp001.azurecr.io/prod-app:latest \\
  --docker-registry-server-url https://prodacrapp001.azurecr.io

# Create deployment slot
az webapp deployment slot create \\
  --resource-group prod-rg-app-001 \\
  --name prod-web-app-001 \\
  --slot green

# Swap slots
az webapp deployment slot swap \\
  --resource-group prod-rg-app-001 \\
  --name prod-web-app-001 \\
  --slot green

# Configure traffic split
az webapp traffic-routing set \\
  --resource-group prod-rg-app-001 \\
  --name prod-web-app-001 \\
  --distribution green=25
```

## Key learnings

- **App Service plans determine performance and cost**: Shared tier for dev, Standard+ for production
- **Deployment slots enable zero-downtime deployments**: Test in production environment before swapping
- **Container images reduce dependency conflicts**: Same image runs identically in dev, staging, production
- **Traffic shifting reduces deployment risk**: Gradual rollout catches issues before full traffic shift
- **Automated rollback is critical**: Monitor error rates, exceptions post-deployment for quick recovery
- **Multi-region deployment is supported**: Add traffic manager for global distribution

## Deployment results

- **Deployment frequency**: 10+ deployments per day with zero downtime
- **Time to production**: 5 minutes from code commit to production
- **Rollback time**: <1 minute to revert to previous stable version
- **Application availability**: 99.95% uptime with automatic failover

## Architecture decisions

1. **App Service plan**: Standard S1 for consistency, Premium for mission-critical workloads
2. **Deployment strategy**: Blue-green with gradual traffic shift for low-risk deployments
3. **Container strategy**: Separate images for web app and API for independent scaling
4. **CI/CD**: GitHub Actions for automated build, test, deploy on push to main branch

## Related

Module guide: [Compute Services](../../modules/02-compute/). App Service patterns extend to Lab 2 (load balancing) and enterprise architecture project.
