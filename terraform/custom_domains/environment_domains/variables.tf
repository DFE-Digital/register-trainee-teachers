variable hosted_zone {
  type = map(any)
  default = {}
}

variable "multiple_hosted_zones" {
  type = bool
  default = false
}

# Variables for Azure alerts
variable "enable_alerting" { default = false }
variable "pg_actiongroup_name" { default = null }
variable "pg_actiongroup_rg" { default = null }
variable "latency_threshold" {
  default = 1500
}
variable "percent_5xx_threshold" {
  default = 15
}

variable "rate_limit" {
  type = list(object({
    agent        = optional(string)
    priority     = optional(number)
    duration     = optional(number)
    limit        = optional(number)
    selector     = optional(string)
    operator     = optional(string)
    match_values = optional(string)
  }))
  default = null
}
