resource "digitalocean_droplet" "www-1" {
  image  = "rockylinux-9-x64"
  name   = "www-1"
  region = "tor1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    var.pvt_key
  ]
}

