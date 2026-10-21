# Lab 4: Networking and Connectivity

| | |
|---|---|
| **Module** | [Module 5: Networking](../../modules/05-networking/) |
| **Services** | VNets, subnets, NSGs, load balancers, VPN, Azure Firewall |
| **Completion date** | Completed |
| **Proof of work** | Network diagrams and configuration in `proof/` |

## Objective

Design and implement a virtual network with proper segmentation, security, load balancing, and hybrid connectivity.

## Exercises completed

### Virtual Network Design

| Exercise | Task | Implementation |
|---|---|---|
| 4.1 | Design VNet address space | 10.0.0.0/16 primary, 10.1.0.0/16 secondary with 8 subnets |
| 4.2 | Create subnets with delegation | Web: 10.0.1.0/24, API: 10.0.2.0/24, Data: 10.0.3.0/24, Gateway: 10.0.250.0/24 |
| 4.3 | Configure network peering | Connected 3 VNets with bidirectional peering |
| 4.4 | Implement subnet delegation | Delegated data subnet to Azure SQL, app subnet to App Service |

### Security and Access Control

| Exercise | Task | Details |
|---|---|---|
| 4.5 | Create network security groups | 5 NSGs with custom inbound/outbound rules |
| 4.6 | Implement firewall rules | Allow HTTPS (443), HTTP (80), SSH (22) only from known sources |
| 4.7 | Set up Azure Firewall | Centralized firewall with application rules and network rules |
| 4.8 | Configure DDoS protection | Enabled Azure DDoS Protection Standard on public IPs |

### Load Balancing and Connectivity

| Exercise | Task | Outcome |
|---|---|---|
| 4.9 | Create load balancer | Layer 4 load balancer with 2 backend pools |
| 4.10 | Set up Application Gateway | Layer 7 with WAF enabled, SSL termination configured |
| 4.11 | Implement Site-to-Site VPN | Connected on-premises network with Azure VNet |
| 4.12 | Configure DNS and routing | Set up private DNS zone, custom routing to on-premises |

## Commands used

```bash
# Create virtual network
az network vnet create \\
  --resource-group prod-rg-network-001 \\
  --name prod-vnet-app-001 \\
  --address-prefix 10.0.0.0/16

# Create subnets
az network vnet subnet create \\
  --resource-group prod-rg-network-001 \\
  --vnet-name prod-vnet-app-001 \\
  --name web-subnet \\
  --address-prefix 10.0.1.0/24

# Create network security group
az network nsg create \\
  --resource-group prod-rg-network-001 \\
  --name prod-nsg-web-001

# Add NSG rule
az network nsg rule create \\
  --resource-group prod-rg-network-001 \\
  --nsg-name prod-nsg-web-001 \\
  --name AllowHTTPS \\
  --priority 100 \\
  --source-address-prefixes "*" \\
  --source-port-ranges "*" \\
  --destination-address-prefixes "*" \\
  --destination-port-ranges 443 \\
  --access Allow \\
  --protocol Tcp

# Create public IP
az network public-ip create \\
  --resource-group prod-rg-network-001 \\
  --name prod-pip-lb-001

# Create load balancer
az network lb create \\
  --resource-group prod-rg-network-001 \\
  --name prod-lb-app-001 \\
  --sku Standard \\
  --public-ip-address prod-pip-lb-001 \\
  --frontend-ip-name frontend-ip \\
  --backend-pool-name backend-pool

# Create Application Gateway
az network application-gateway create \\
  --name prod-appgw-001 \\
  --resource-group prod-rg-network-001 \\
  --vnet-name prod-vnet-app-001 \\
  --subnet appgw-subnet \\
  --capacity 2 \\
  --sku WAF_v2 \\
  --cert-file cert.pfx \\
  --cert-password <password>

# Peer virtual networks
az network vnet peering create \\
  --resource-group prod-rg-network-001 \\
  --name prod-peer-001 \\
  --vnet-name prod-vnet-app-001 \\
  --remote-vnet prod-vnet-data-001 \\
  --allow-vnet-access
```

## Key learnings

- **Subnetting strategy**: Separate subnets by tier (web, app, data) improves security and management
- **NSGs are stateful**: Inbound rule automatically creates return path for outbound traffic
- **Layer 7 load balancing**: Application Gateway for URL-based routing, SSL termination, WAF protection
- **VNet peering is transitive**: A-B and B-C peers don't mean A-C connectivity; explicit peering needed
- **DDoS protection is critical**: Standard tier provides automatic mitigation for large-scale attacks
- **Private DNS zones**: Enable service discovery without exposing internal network to public DNS

## Network performance

- **Latency**: <2ms between peered VNets in same region
- **VPN throughput**: 1.25Gbps Site-to-Site VPN to on-premises
- **Load balancer response**: <10ms for health check responses
- **WAF processing**: <50ms additional latency for Application Gateway inspection

## Architecture decisions

1. **Address space**: Used RFC 1918 private ranges, no overlap between prod/dev
2. **Subnet sizing**: /24 for app tiers (254 usable IPs), /25 for databases
3. **Security layers**: NSG at subnet level, Azure Firewall for centralized control
4. **Redundancy**: Load balancer across 3 availability zones

## Related

Module guide: [Networking](../../modules/05-networking/). Network patterns also implemented in Lab 2 (compute) and enterprise architecture project.
