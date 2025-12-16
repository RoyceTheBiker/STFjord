resource "digitalocean_droplet" "webmail" {
  image  = "rockylinux-9-x64"
  name   = "email"
  region = "tor1"
  size   = "s-2vcpu-4gb"
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  monitoring = true # Enable the Digital Ocean metrics agent
  ipv6       = false
}

resource "digitalocean_reserved_ip_assignment" "webmil_ip" {
  ip_address = var.reserved_ip
  droplet_id = digitalocean_droplet.webmail.id
}

resource "null_resource" "payload" {
  depends_on = [digitalocean_reserved_ip_assignment.webmil_ip]

  connection {
    type  = "ssh"
    host  = var.reserved_ip
    user  = "root"
    agent = true
  }

  provisioner "file" {
    source      = var.settings_json
    destination = "/root/settings.json"
  }

  provisioner "file" {
    source      = "./payload"
    destination = "/root/payload"
  }
  provisioner "remote-exec" {
    inline = [
      "export ADMIN_IP='${chomp(data.http.myip.response_body)}'",
      "bash /root/payload/payload.sh"
    ]
  }

}
