variable "do_token" {
  description = "The Digital Ocean access token"
  type        = string
}

variable "reserved_ip" {
  description = "Reserved Public IP"
  default     = ""
  type        = string
}

variable "settings_json" {
  description = "The settings.json file to upload"
  default     = ""
  type        = string
}

