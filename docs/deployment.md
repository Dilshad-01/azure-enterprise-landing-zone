# Deployment Guide

## Prerequisites

Before deploying the Azure Landing Zone, ensure you have:

1. **Azure Subscription** with Owner permissions
2. **Azure CLI** 2.50.0 or later installed
3. **Terraform** 1.5.0 or later installed
4. **GitHub Account** with Actions enabled
5. **Service Principal** with appropriate permissions

## Initial Setup

### 1. Azure CLI Login

```bash
az login
az account set --subscription <subscription-id>
```

### 2. Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "terraform-sp" \
  --role "Owner" \
  --scopes /subscriptions/<subscription-id>
```

Save the output:
- `appId` → `AZURE_CLIENT_ID`
- `password` → `AZURE_CLIENT_SECRET`
- `tenant` → `AZURE_TENANT_ID`

### 3. Configure GitHub Secrets

In your GitHub repository, go to Settings → Secrets and variables → Actions, and add:

- `AZURE_CLIENT_ID`: Service Principal App ID
- `AZURE_CLIENT_SECRET`: Service Principal Password
- `AZURE_TENANT_ID`: Azure AD Tenant ID
- `AZURE_SUBSCRIPTION_ID`: Azure Subscription ID

### 4. Configure Terraform Backend

Create a storage account for Terraform state:

```bash
# Create resource group for Terraform state
az group create \
  --name RG_TFSTATE_djs01224 \
  --location eastus

# Create storage account
az storage account create \
  --name sttfstatedjs01224 \
  --resource-group RG_TFSTATE_djs01224 \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name sttfstatedjs01224
```

Update backend configuration in `infrastructure/*/main.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "RG_TFSTATE_djs01224"
  storage_account_name = "sttfstatedjs01224"
  container_name       = "tfstate"
  key                  = "management-groups.terraform.tfstate"
}
```

### 5. Customize Configuration

Copy and edit the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

## Deployment Order

Deploy infrastructure in the following order:

1. **Management Groups** (foundation)
2. **Hub Network** (connectivity)
3. **Policies** (governance)
4. **RBAC** (access control)
5. **Spoke Networks** (workloads)

### Step 1: Deploy Management Groups

```bash
cd infrastructure/management-groups
terraform init
terraform plan
terraform apply
```

### Step 2: Deploy Hub Network

```bash
cd infrastructure/hub
terraform init
terraform plan
terraform apply
```

Save the outputs:
- `firewall_private_ip`: Needed for spoke deployments
- `hub_virtual_network_id`: Needed for policies

### Step 3: Deploy Policies

```bash
cd infrastructure/policies/security
terraform init
terraform plan
terraform apply

cd ../networking
terraform init
terraform plan
terraform apply

cd ../compliance
terraform init
terraform plan
terraform apply

cd ../cost
terraform init
terraform plan
terraform apply
```

### Step 4: Assign Policies to Management Groups

Create policy assignments at the management group level:

```bash
# Example: Assign security policy to Production management group
az policy assignment create \
  --name "require-nsg-on-subnets" \
  --display-name "Require NSG on Subnets" \
  --policy <policy-definition-id> \
  --scope /providers/Microsoft.Management/managementGroups/production
```

### Step 5: Deploy RBAC

```bash
cd infrastructure/rbac
terraform init
terraform plan
terraform apply
```

### Step 6: Deploy Spoke Networks

#### Production Spoke

```bash
cd infrastructure/spoke/production
terraform init
terraform plan \
  -var="hub_resource_group_name=RG_djs01224" \
  -var="hub_vnet_name=VNET_djs01224" \
  -var="firewall_private_ip=<firewall-private-ip>"
terraform apply
```

#### Non-Production Spoke

```bash
cd infrastructure/spoke/non-production
terraform init
terraform plan \
  -var="hub_resource_group_name=RG_djs01224" \
  -var="hub_vnet_name=VNET_djs01224" \
  -var="firewall_private_ip=<firewall-private-ip>"
terraform apply
```

## CI/CD Deployment

### Manual Deployment via GitHub Actions

1. Go to Actions tab in GitHub
2. Select "Terraform Apply" workflow
3. Click "Run workflow"
4. Select environment and options
5. Click "Run workflow"

### Automated Deployment

- **Push to `develop`**: Auto-deploys to non-production (with auto-approve)
- **Push to `main`**: Requires manual approval for production deployment
- **Pull Request**: Runs validation and plan only

## Post-Deployment Validation

### Verify Network Connectivity

```bash
# Test connectivity from spoke to hub
az network vnet peering show \
  --name PEERING_djs01224_01 \
  --resource-group RG_djs01224_01 \
  --vnet-name VNET_djs01224_01
```

### Verify Policy Compliance

```bash
# Check policy compliance
az policy state list \
  --resource /subscriptions/<subscription-id>
```

### Verify RBAC

```bash
# List role assignments
az role assignment list \
  --scope /subscriptions/<subscription-id>
```

### Verify Firewall Rules

```bash
# List firewall rules
az network firewall application-rule list \
  --firewall-name FW_djs01224 \
  --resource-group RG_djs01224
```

## Troubleshooting

### Common Issues

1. **Terraform State Lock**
   ```bash
   # If state is locked, unlock it
   terraform force-unlock <lock-id>
   ```

2. **Permission Errors**
   - Verify service principal has Owner role
   - Check management group permissions

3. **Network Peering Failures**
   - Verify address spaces don't overlap
   - Check both sides of peering are created

4. **Policy Assignment Failures**
   - Verify policy definition exists
   - Check management group hierarchy

## Rollback

To rollback a deployment:

```bash
# Revert to previous state
terraform state pull > current-state.json
terraform state push previous-state.json
```

Or use Terraform Cloud/Enterprise for state versioning.

## Cleanup

To destroy resources:

```bash
# Destroy in reverse order
cd infrastructure/spoke/production
terraform destroy

cd ../non-production
terraform destroy

cd ../../rbac
terraform destroy

cd ../policies/...
terraform destroy

cd ../../hub
terraform destroy

cd ../management-groups
terraform destroy
```

**Warning**: This will delete all resources. Ensure you have backups before destroying.

## Next Steps

After deployment:

1. Configure Azure Firewall rules
2. Set up VPN/ExpressRoute connectivity
3. Deploy workloads to spoke networks
4. Configure monitoring and alerting
5. Set up cost budgets and alerts
6. Configure backup and disaster recovery

