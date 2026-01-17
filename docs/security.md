# Security Documentation

## Security Model

This document outlines the security architecture and controls implemented in the Azure Landing Zone.

## Defense in Depth

The landing zone implements multiple layers of security:

1. **Network Layer**: NSGs, Azure Firewall, Private Endpoints
2. **Identity Layer**: RBAC, PIM, Managed Identities
3. **Data Layer**: Encryption at rest and in transit
4. **Application Layer**: Security policies and compliance controls

## Network Security

### Network Security Groups (NSGs)

- **Default Deny**: All traffic denied unless explicitly allowed
- **Application-Specific Rules**: NSGs tailored to each application tier
- **Service Tags**: Use Azure service tags for Azure service communication
- **Application Security Groups**: For dynamic NSG rule management

### Azure Firewall

- **Centralized Security**: All internet-bound traffic inspected
- **Threat Intelligence**: Automatic blocking of known malicious IPs
- **Application Rules**: FQDN-based filtering
- **Network Rules**: IP/port-based filtering
- **Logging**: All traffic logged to Log Analytics

### Private Endpoints

- **PaaS Services**: All Azure PaaS services accessed via private endpoints
- **DNS Integration**: Private DNS zones for name resolution
- **No Public Exposure**: Eliminate public endpoints for internal services

## Identity and Access Management

### Role-Based Access Control (RBAC)

#### Custom Roles

1. **Platform Administrator**
   - Full control over hub subscription
   - Cannot access workload subscriptions
   - Manages network, firewall, and shared services

2. **Network Administrator**
   - Manages network resources (VNets, NSGs, peering)
   - Cannot modify firewall rules
   - Read-only access to hub subscription

3. **Security Administrator**
   - Read access to all subscriptions
   - Manages security policies and Key Vault
   - Views security logs and alerts

4. **Landing Zone Owner**
   - Contributor rights to assigned subscription
   - Cannot modify network peering or hub resources
   - Can deploy and manage resources

### Privileged Identity Management (PIM)

- **Just-in-Time Access**: Elevated permissions activated only when needed
- **Time-Limited**: Access expires after specified duration
- **Approval Workflow**: Critical roles require manager approval
- **Audit Trail**: All privilege escalations logged

### Service Principals

- **Least Privilege**: Minimal required permissions
- **Managed Identity**: Preferred over service principals
- **Key Vault Integration**: Secrets stored in Key Vault
- **Rotation**: Automated credential rotation

## Data Protection

### Encryption at Rest

- **Storage Accounts**: Azure Storage encryption enabled
- **Virtual Machines**: Azure Disk Encryption
- **Databases**: Transparent Data Encryption (TDE)
- **Key Vault**: Hardware Security Module (HSM) backed

### Encryption in Transit

- **TLS 1.2+**: Required for all connections
- **HTTPS Only**: For storage accounts and web applications
- **VPN/ExpressRoute**: Encrypted connections to on-premises

### Key Management

- **Azure Key Vault**: Centralized key and secret management
- **Access Policies**: Restricted access to Key Vault
- **Network Restrictions**: Key Vault accessible only from approved networks
- **Audit Logging**: All Key Vault access logged

## Security Policies

### Network Policies

- Require NSG on all subnets
- Enforce private endpoints for PaaS services
- Block public IPs on VMs (with exceptions)
- Enforce VNet peering to hub only

### Identity Policies

- Require MFA for all user accounts
- Enforce conditional access policies
- Block service principals with owner role
- Require managed identities for applications

### Data Protection Policies

- Enforce encryption at rest for all storage accounts
- Require TLS 1.2+ for all connections
- Enforce Azure Disk Encryption for VMs
- Require Key Vault for secrets management

### Compliance Policies

- Enforce resource tagging (Environment, CostCenter, Owner)
- Require diagnostic settings for all resources
- Enforce log retention policies
- Block deployment of non-compliant resource types

## Threat Detection

### Azure Sentinel

- **SIEM**: Security information and event management
- **Threat Detection**: Machine learning-based threat detection
- **Incident Response**: Automated incident creation and response
- **Hunting**: Proactive threat hunting capabilities

### Azure Security Center

- **Security Posture**: Continuous security assessment
- **Recommendations**: Security best practice recommendations
- **Threat Protection**: Real-time threat protection
- **Compliance**: Regulatory compliance monitoring

## Security Monitoring

### Log Analytics

- **Centralized Logging**: All security logs in one place
- **90-Day Retention**: Security logs retained for 90 days
- **Query Capabilities**: KQL queries for security analysis
- **Alerting**: Automated alerts for security events

### Diagnostic Settings

- **Resource Logs**: All resources send logs to Log Analytics
- **Activity Logs**: All administrative actions logged
- **Security Logs**: Security events and alerts logged

## Incident Response

### Response Plan

1. **Detection**: Automated detection via Azure Sentinel
2. **Investigation**: Security team investigates alerts
3. **Containment**: Isolate affected resources
4. **Eradication**: Remove threat
5. **Recovery**: Restore services
6. **Lessons Learned**: Post-incident review

### Automation

- **Playbooks**: Automated response playbooks in Azure Sentinel
- **Runbooks**: Azure Automation runbooks for common tasks
- **Notifications**: Automated notifications to security team

## Compliance

### Standards

- **SOC 2 Type II**: Service Organization Control 2
- **ISO 27001**: Information security management
- **HIPAA**: Health Insurance Portability and Accountability Act (if applicable)
- **PCI DSS**: Payment Card Industry Data Security Standard (if applicable)

### Audit Logging

- **90-Day Retention**: Security logs retained for 90 days
- **1-Year Retention**: Audit logs retained for 1 year
- **Immutable Logs**: Logs cannot be modified or deleted
- **Access Control**: Restricted access to audit logs

## Security Best Practices

### Regular Reviews

- **Access Reviews**: Quarterly access reviews
- **Policy Reviews**: Annual policy reviews
- **Security Assessments**: Annual security assessments
- **Penetration Testing**: Annual penetration testing

### Training

- **Security Awareness**: Regular security awareness training
- **Role-Specific Training**: Training for specific roles
- **Incident Response Training**: Regular incident response drills

### Continuous Improvement

- **Threat Intelligence**: Stay updated on latest threats
- **Security Updates**: Regular security updates and patches
- **Policy Updates**: Update policies based on lessons learned
- **Tool Evaluation**: Regular evaluation of security tools

