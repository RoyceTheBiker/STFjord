variable "do_token" {
  description = "The Digital Ocean access token"
  type        = string
}

variable "MX_HOST" {
  description = "The hostname of the email server"
  type        = string
}

variable "MX_DOMAIN" {
  description = "The domain name of the email server"
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

