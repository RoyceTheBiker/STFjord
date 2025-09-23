resource "digitalocean_droplet" "webmail" {
  image  = "rockylinux-9-x64"
  name   = "email"
  region = "tor1"
  size   = "s-1vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    type  = "ssh"
    host  = self.ipv4_address
    user  = "root"
    agent = true
  }

  provisioner "file" {
    source      = "./payload.sh"
    destination = "/root/payload.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/payload.sh"
    ]
  }
}


resource "digitalocean_reserved_ip_assignment" "example" {
  ip_address = var.reserved_ip
  droplet_id = digitalocean_droplet.webmail.id
}


