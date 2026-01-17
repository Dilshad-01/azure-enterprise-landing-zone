# Architecture Documentation

## Overview

This document provides detailed architecture information for the Enterprise Azure Landing Zone.

## Network Architecture

### Hub-Spoke Topology

The landing zone implements a hub-spoke network architecture where:

- **Hub Network**: Central connectivity point for all spoke networks
- **Spoke Networks**: Isolated networks for different workloads and environments

### Address Space Allocation

| Network | Address Space | Purpose |
|---------|--------------|---------|
| Hub | 10.0.0.0/16 | Shared services and connectivity |
| Production Spoke 1 | 10.1.0.0/16 | Production workloads |
| Production Spoke 2 | 10.2.0.0/16 | Production workloads (secondary) |
| Non-Production Spoke 1 | 10.10.0.0/16 | Development workloads |
| Non-Production Spoke 2 | 10.20.0.0/16 | Testing workloads |

### Subnet Design

#### Hub Subnets

- **AzureFirewallSubnet** (10.0.0.0/26): Azure Firewall
- **AzureBastionSubnet** (10.0.0.64/26): Azure Bastion Host
- **GatewaySubnet** (10.0.0.128/27): VPN/ExpressRoute Gateway
- **SharedServicesSubnet** (10.0.1.0/24): Shared infrastructure services
- **DMZSubnet** (10.0.2.0/24): Public-facing services

#### Spoke Subnets

- **WebSubnet**: Web tier applications
- **AppSubnet**: Application tier
- **DataSubnet**: Database tier

## Security Architecture

### Network Security

1. **Network Security Groups (NSGs)**: Applied to all subnets
2. **Azure Firewall**: Centralized network security and inspection
3. **Private Endpoints**: All PaaS services accessed via private endpoints
4. **Route Tables**: Force traffic through Azure Firewall

### Identity and Access

1. **RBAC**: Role-based access control with custom roles
2. **PIM**: Privileged Identity Management for elevated access
3. **Managed Identities**: For service-to-service authentication
4. **Service Principals**: For CI/CD automation

### Policy Enforcement

1. **Security Policies**: Enforce security best practices
2. **Network Policies**: Control network configuration
3. **Compliance Policies**: Ensure regulatory compliance
4. **Cost Policies**: Control spending and resource SKUs

## Management Group Hierarchy

```
Root Management Group
├── Platform Management Group
│   └── Hub Subscription
└── Landing Zones Management Group
    ├── Production Management Group
    │   ├── Production Subscription 1
    │   └── Production Subscription 2
    ├── Non-Production Management Group
    │   ├── Development Subscription
    │   └── Testing Subscription
    └── Sandbox Management Group
        └── Sandbox Subscription
```

## Resource Organization

### Resource Groups

Resources are organized into resource groups by function:

- **RG_djs01224**: Hub network resources
- **RG_djs01224_01**: Production spoke resources
- **RG_djs01224_02**: Non-production spoke resources

### Naming Conventions

Resources follow a consistent naming pattern with the suffix `djs01224`:

- **Resource Groups**: `RG_djs01224`, `RG_djs01224_01`, `RG_djs01224_02` (for multiple)
- **Virtual Networks**: `VNET_djs01224`, `VNET_djs01224_01`, `VNET_djs01224_02`
- **Subnets**: `{tier}Subnet` (e.g., `AppSubnet`, `DataSubnet`, `WebSubnet`)
- **Network Security Groups**: `NSG_djs01224`, `NSG_djs01224_01`, `NSG_djs01224_02`
- **Route Tables**: `RT_djs01224_01`, `RT_djs01224_02`
- **Azure Firewall**: `FW_djs01224`
- **Key Vault**: `KV_djs01224`
- **Log Analytics Workspace**: `LAW_djs01224`
- **Bastion Host**: `BASTION_djs01224`
- **Public IPs**: `PIP_FW_djs01224`, `PIP_BASTION_djs01224`
- **VNet Peerings**: `PEERING_djs01224_01`, `PEERING_djs01224_02`, etc.

## Connectivity

### On-Premises Connectivity

- **VPN Gateway**: Site-to-site VPN for remote offices
- **ExpressRoute**: Dedicated private connection for datacenters

### Internet Connectivity

- All internet-bound traffic routed through Azure Firewall
- No direct internet access from spoke networks
- Azure Firewall provides threat intelligence and filtering

## Monitoring and Logging

### Log Analytics Workspace

Centralized logging for:
- Azure Firewall logs
- Network Security Group logs
- Virtual Machine logs
- Application logs
- Security logs

### Diagnostic Settings

All resources have diagnostic settings configured to send logs to Log Analytics.

## High Availability

### Regional Deployment

- Primary region: East US
- Secondary region: West US (for disaster recovery)

### Availability Zones

Critical resources deployed across availability zones:
- Azure Firewall: Zone-redundant
- Virtual Machines: Multiple zones
- Load Balancers: Zone-redundant

## Disaster Recovery

### Backup Strategy

- **Virtual Machines**: Azure Backup
- **Storage Accounts**: Geo-redundant storage
- **Databases**: Automated backups with geo-replication

### Recovery Objectives

- **RTO**: 4 hours
- **RPO**: 1 hour

## Cost Optimization

### Reserved Instances

- 1-year reservations for predictable workloads
- 3-year reservations for stable services

### Auto-Shutdown

- Non-production VMs automatically shut down during off-hours
- Scheduled start/stop for cost savings

### Resource Tagging

All resources tagged with:
- Environment
- CostCenter
- Owner
- Project

## Compliance

### Standards

- SOC 2 Type II
- ISO 27001
- HIPAA (if applicable)

### Audit Logging

- All administrative actions logged
- 90-day retention for security logs
- 1-year retention for audit logs

