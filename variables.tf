variable "do_token" {
  description = "The Digital Ocean access token"
  type        = string
}

variable "myip" {
  description = "The IP address of the system where these scripts are ran."
  default     = ""

}
variable "reserved_ip" {
  description = "Reserved Public IP"
  default     = ""
}




