variable "scope" {
  description = "The scope at which the role definition is created"
  type        = string
}

variable "platform_admin_group_object_id" {
  description = "Object ID of the Platform Administrators Azure AD group"
  type        = string
  default     = ""
}

variable "network_admin_group_object_id" {
  description = "Object ID of the Network Administrators Azure AD group"
  type        = string
  default     = ""
}

variable "security_admin_group_object_id" {
  description = "Object ID of the Security Administrators Azure AD group"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

