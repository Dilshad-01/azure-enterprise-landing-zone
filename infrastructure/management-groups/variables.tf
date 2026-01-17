variable "root_management_group_id" {
  description = "The ID of the root management group"
  type        = string
  default     = "root"
}

variable "platform_subscriptions" {
  description = "List of subscription IDs to associate with Platform management group"
  type        = list(string)
  default     = []
}

variable "production_subscriptions" {
  description = "List of subscription IDs to associate with Production management group"
  type        = list(string)
  default     = []
}

variable "nonproduction_subscriptions" {
  description = "List of subscription IDs to associate with Non-Production management group"
  type        = list(string)
  default     = []
}

variable "sandbox_subscriptions" {
  description = "List of subscription IDs to associate with Sandbox management group"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

