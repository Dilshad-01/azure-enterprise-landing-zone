terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {}
}

# Policy Definition: Require Resource Tags
resource "azurerm_policy_definition" "require_resource_tags" {
  name         = "require-resource-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Mandatory Resource Tags"
  description  = "This policy ensures that all resources have required tags"

  parameters = jsonencode({
    tagName1 = {
      type = "String"
      metadata = {
        displayName = "Tag Name 1 (Environment)"
        description = "Name of the tag, such as 'Environment'"
      }
    }
    tagName2 = {
      type = "String"
      metadata = {
        displayName = "Tag Name 2 (CostCenter)"
        description = "Name of the tag, such as 'CostCenter'"
      }
    }
    tagName3 = {
      type = "String"
      metadata = {
        displayName = "Tag Name 3 (Owner)"
        description = "Name of the tag, such as 'Owner'"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field = "[concat('tags[', parameters('tagName1'), ']')]"
          exists = false
        },
        {
          field = "[concat('tags[', parameters('tagName2'), ']')]"
          exists = false
        },
        {
          field = "[concat('tags[', parameters('tagName3'), ']')]"
          exists = false
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Enforce Tag Values
resource "azurerm_policy_definition" "enforce_tag_values" {
  name         = "enforce-tag-values"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Enforce Allowed Tag Values"
  description  = "This policy ensures that tag values match allowed values"

  parameters = jsonencode({
    tagName = {
      type = "String"
      metadata = {
        displayName = "Tag Name"
        description = "Name of the tag to enforce"
      }
    }
    allowedValues = {
      type = "Array"
      metadata = {
        displayName = "Allowed Values"
        description = "List of allowed values for the tag"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "[concat('tags[', parameters('tagName'), ']')]"
          exists = true
        },
        {
          field = "[concat('tags[', parameters('tagName'), ']')]"
          notIn = "[parameters('allowedValues')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition: Require Log Retention
resource "azurerm_policy_definition" "require_log_retention" {
  name         = "require-log-retention"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Minimum Log Retention Period"
  description  = "This policy ensures that Log Analytics workspaces have minimum retention configured"

  parameters = jsonencode({
    minimumRetentionDays = {
      type = "Integer"
      metadata = {
        displayName = "Minimum Retention Days"
        description = "Minimum number of days logs must be retained"
      }
      defaultValue = 90
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.OperationalInsights/workspaces"
        },
        {
          anyOf = [
            {
              field = "Microsoft.OperationalInsights/workspaces/retentionInDays"
              less = "[parameters('minimumRetentionDays')]"
            },
            {
              field = "Microsoft.OperationalInsights/workspaces/retentionInDays"
              exists = false
            }
          ]
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

