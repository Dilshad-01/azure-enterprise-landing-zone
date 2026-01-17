#!/bin/bash

# Azure Landing Zone Setup Script
# This script helps set up the initial environment for deploying the Azure Landing Zone

set -e

echo "========================================="
echo "Azure Landing Zone Setup"
echo "========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install Azure CLI 2.50.0 or later."
    exit 1
fi
echo "✅ Azure CLI found: $(az --version | head -n 1)"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install Terraform 1.5.0 or later."
    exit 1
fi
echo "✅ Terraform found: $(terraform version | head -n 1)"

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi
echo "✅ Logged in to Azure"

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

echo ""
echo "Current Azure Subscription:"
echo "  Name: $SUBSCRIPTION_NAME"
echo "  ID: $SUBSCRIPTION_ID"
echo "  Tenant ID: $TENANT_ID"
echo ""

read -p "Continue with this subscription? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please select the correct subscription with 'az account set --subscription <subscription-id>'"
    exit 1
fi

# Create service principal
echo ""
echo "Creating service principal for Terraform..."
SP_NAME="terraform-sp-$(date +%s)"
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role "Owner" \
    --scopes "/subscriptions/$SUBSCRIPTION_ID" \
    --output json)

CLIENT_ID=$(echo $SP_OUTPUT | jq -r '.appId')
CLIENT_SECRET=$(echo $SP_OUTPUT | jq -r '.password')

echo "✅ Service principal created: $SP_NAME"
echo ""
echo "⚠️  IMPORTANT: Save these credentials securely!"
echo "   AZURE_CLIENT_ID: $CLIENT_ID"
echo "   AZURE_CLIENT_SECRET: $CLIENT_SECRET"
echo "   AZURE_TENANT_ID: $TENANT_ID"
echo "   AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo ""

# Create Terraform state storage
echo "Creating storage account for Terraform state..."
RESOURCE_GROUP="RG_TFSTATE_djs01224"
STORAGE_ACCOUNT="sttfstatedjs01224$(date +%s | tail -c 7)"
CONTAINER="tfstate"

az group create \
    --name "$RESOURCE_GROUP" \
    --location "eastus" \
    --output none

az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "eastus" \
    --sku Standard_LRS \
    --output none

az storage container create \
    --name "$CONTAINER" \
    --account-name "$STORAGE_ACCOUNT" \
    --output none

echo "✅ Storage account created: $STORAGE_ACCOUNT"
echo ""
echo "Update your Terraform backend configuration with:"
echo "  resource_group_name  = \"$RESOURCE_GROUP\""
echo "  storage_account_name = \"$STORAGE_ACCOUNT\""
echo "  container_name       = \"$CONTAINER\""
echo ""

# Create example tfvars file
if [ ! -f "terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    
    # Update with actual values
    sed -i.bak "s/00000000-0000-0000-0000-000000000000/$TENANT_ID/g" terraform.tfvars
    sed -i.bak "s/subscription_id = .*/subscription_id = \"$SUBSCRIPTION_ID\"/g" terraform.tfvars
    
    rm terraform.tfvars.bak 2>/dev/null || true
    
    echo "✅ Created terraform.tfvars (please review and update as needed)"
else
    echo "⚠️  terraform.tfvars already exists, skipping creation"
fi

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Review and update terraform.tfvars"
echo "2. Configure GitHub Secrets with the service principal credentials"
echo "3. Update Terraform backend configuration in infrastructure/*/main.tf"
echo "4. Deploy management groups: cd infrastructure/management-groups && terraform init && terraform apply"
echo ""

