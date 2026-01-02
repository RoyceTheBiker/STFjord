variable "do_token" {
  description = "The Digital Ocean access token"
  type        = string
}

variable "COMMON_NAME" {
  description = "The common name for the TLS"
  default     = ""
  type        = string
}

variable "COUNTRY" {
  description = "The country for the TLS"
  default     = ""
  type        = string
}

variable "ENVIRONMENT" {
  description = "The environment for the scripts"
  default     = ""
  type        = string
}

variable "EMAIL_ACCOUNTS" {
  description = "The email account for the scripts"
  default     = ""
  type        = string
}

variable "LOCATION" {
  description = "The city for the TLS"
  default     = ""
  type        = string
}

variable "MX_HOST" {
  description = "The hostname of the email server"
  default     = "email_host"
  type        = string
}

variable "MX_DOMAIN" {
  description = "The domain name of the email server"
  default     = "email.domain"
  type        = string
}

variable "ORGANIZATION" {
  description = "The organization for the TLS"
  default     = ""
  type        = string
}

variable "ORG_UNIT" {
  description = "The group for the TLS"
  default     = ""
  type        = string
}

variable "reserved_ip" {
  description = "Reserved Public IP"
  type        = string
}

variable "settings_json" {
  description = "The settings.json file to upload"
  type        = string
}

variable "STATE" {
  description = "The region for the TLS"
  default     = ""
  type        = string
}

variable "TIME_ZONE" {
  description = "Timezone of server or orginization"
  default     = ""
  type        = string
}
