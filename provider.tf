terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    template = "2.2.0"
  }
  required_version = ">= 1.14.3"
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "id_ecdsa.pub"
}

