provider "digitalocean" {
  alias = "firewall"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "digitalocean_firewall" "email-firewall" {
  name = replace("${var.MX_HOST}-${var.MX_DOMAIN}-email-firewall", ".", "-")

  droplet_ids = [digitalocean_droplet.webmail.id]

  # Encrypted SSH
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [chomp(data.http.myip.response_body)]
  }

  # Unencrypted HTTP required by Certbot
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0"]
  }

  # Encrypted HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }

  # Encrypted SMTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "465"
    source_addresses = ["0.0.0.0/0"]
  }

  # Encrypted SMTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "587"
    source_addresses = ["0.0.0.0/0"]
  }

  # Encrypted IMAPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "993"
    source_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0"]
  }
}
