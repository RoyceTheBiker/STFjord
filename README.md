# STFjord

Silicon Tao Fjord is where the Rocky Linux meets the DigitalOcean.

This project is provided in a Git repository and builds a Rocky Linux server in DigitalOcean using Terraform. The payload script for Terraform then sets up a Roundcube Webmail service.

This is part 5 in the Rocky Linux webmail series. Parts 1 to 3 are in [Rocky Linux Webmail Server](https://silicontao.com/main/marquis/article/RoyceTheBiker/Rocky%20Linux%20Webmail%20Server). Part 4 is
[ClamAV For Postfix](https://silicontao.com/main/marquis/article/RoyceTheBiker/ClamAV%20for%20Postfix)

Close the Git repository for STFjord

```bash
git clone https://gitlab.com/SiliconTao-Systems/STFjord.git
cd STFjord
```

## Digital Ocean CLI

[Installing doctl Using Homebrew](hamster.com/videos/two-busty-bbws-use-a-skinny-guy-for-sex-xhbJ8kP)

Using the CLI tool requires an API token for DigitalOcean.
Use the DigitalOcean control panel to generate a new token on your DigitalOcean homepage using the API menu entry on the bottom left.

Tokens are valid for 90 days.

Example of using DO API on the command line.

```bash
doctl auth init
doctl apps list-regions # To get a list of regions
doctl compute size list # To get a list of Droplet sizes
```

[![Testing the token](https://cdn.silicontao.com/RockyLinuxWebmail/doctl_token_sm.png)](https://cdn.silicontao.com/RockyLinuxWebmail/doctl_token.png)

## Helpful Links

[How To Use Terraform with DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean)

[DO Images](https://docs.digitalocean.com/products/droplets/details/images/)

[DO Images API](https://docs.digitalocean.com/reference/api/digitalocean/#tag/GradientAI-Platform/operation/genai_get_workspace)

[DO Regions](https://docs.digitalocean.com/platform/regional-availability/)

[Choosing a Droplet size](https://docs.digitalocean.com/products/droplets/concepts/choosing-a-plan/)

[Droplet CPU and RAM sizes](https://www.digitalocean.com/community/questions/how-to-identify-the-same-sizes-as-are-available-through-the-web-interface)
[Create a personal access token](https://docs.digitalocean.com/reference/api/create-personal-access-token/)

[Remote State](https://docs.digitalocean.com/products/spaces/reference/terraform-backend/)

[DigitalOcean Metrics Agent](https://docs.digitalocean.com/products/monitoring/how-to/install-metrics-agent/)

A token is required to run Terraform. The Terraform API needs to perform actions in the cloud provider API as an authorized administrator.

# Building

Setting up a public server requires it to use signed certificates. We can use [Let's Encrypt](https://letsencrypt.org/) to create signed certificates for free, but the certificates are only valid for 90 days. This requires us to set up [CertBot](https://certbot.eff.org/) to automatically renew our certificates.

For CertBot to work, port 80 must be accessible to the public Internet, and no service can be using the port. When CertBot runs, it will start a service on port 80 and send a request for verification to **Let's Encrypt** to get a new signed certificate. For this to happen, the IP address must be registered in public DNS so that the host is resolvable by name. This is important because IP addresses cannot obtain signed certificates. The controller of the hostname (FQDN) in public DNS records is considered the authority for the FQDN (Fully Qualified Domain Name).

When building a server manually, one can start the server, then register the IP address with the DNS chosen to control the FQDN. Once the public DNS can resolve the hostname, an administrator can return later to set up CertBot, generate certificates, and configure the server to use encrypted ports. This cannot be done when using Terraform to deploy the server.

For Terraform to deploy the server and have it use CertBot for creating signed certificates, one of two things must be true. Terraform configures the DNS records hosted by the cloud provider, and services remain in an off state until CertBot can resolve the hostname on the public DNS, or the IP address must be reserved in advance, and a DNS record to resolve the hostname is registered.

Silicon Tao uses the DNS provided by the domain registrar, so the first option does not work.

Using DigitalOcean IP reservation, we can stake a claim to an IPv4 address, register the IP with our DNS, and return later to run the Terraform project to build our email server and set up the encrypted services using signed certificates.

 [![Reserved IP](https://cdn.silicontao.com/RockyLinuxWebmail/DO_reserved_IP_address_SM.png)](https://cdn.silicontao.com/RockyLinuxWebmail/DO_reserved_IP_address.png)

<!-- 
# Plugins For Roundcube

## MFA

Common Types of Multi-Factor Authentication

- Google Authenticator
- YubiKey
- SMS

-->

# Terraforming

## The Payload

Everyone who uses this project will need to edit **payload/payload.sh**, or completely replace the **payload** directory.

Replace the entire **payload** to use this project as a template to build a different project in DigitalOcean using Terraform.

### Payload Variables

#### MX_DOMAIN

The minimum change required would be to change **MX_DOMAIN** to match your MX domain registration.

The payload has been configured to install a mail server for **mWorks.tech**. This domain belongs to SiliconTao.com, and the MX record is controlled by SiliconTao.com DNS. Not changing these values will cause your mail server to not work.

#### ENVIRONMENT

In [Part 3 of the Rocky Linux Webmail](https://www.youtube.com/watch?v=iVKNTxWYQcU) videos, user accounts were set up using only **password** as the password.
In the payload, a new variable was added for ENVIRONMENT. If ENVIRONMENT is set to "PROD", as it is in **payload.sh**, random passwords are generated for the user accounts. This password is not saved or logged anywhere. The administrator must SSH into the mail server in PROD and change the user's password. Changing the ENVIRONMENT value to DEV will cause it to use **password** as the password, and that is not recommended in a production environment.

The major steps in the **payload.sh** are:

- Install and setup CertBot, creating signed certificates and a cron job to renew the cert.
- Install RoundCube, Postfix, and Dovecot from parts 1, 2, and 3
- Install ClamAV for Postfix from part 4
- Harden the services, change to using encrypted ports using the signed certificates

## Init

Before running Terraform, the project needs to run **init**. That will read the Terraform source files and download the necessary modules to deploy to DigitalOcean.

```bash
terraform init
```

Copy the **settings.example.json** file to a private directory outside of the project, renaming it **settings.json**, and replace the two values in it, your admin token from DigitalOcean and the reserved IP that has been assigned to the MX record.

[Context: "settings.json"]

```json
{
        "do_token": "dop_v1_abcdefghijklmnop1234567890",
        "reserved_ip": "1.2.3.4"
}
```

This **settings.json** file does not contain the settings used in **payload.json**. This allows the STFjord project to be used with custom payloads and no Terraform code changes.

## Plan

```bash
terraform plan --var-file=~/settings.json

```

## Apply

This is the command that will begin building the Droplet and run the scripts to install Roundcube Webmail.

```bash
terraform apply --var-file=~/settings.json
```

## Destroy

For development only, using the **destroy** command completely removes the Droplet, leaving nothing behind from the project.
Repeatedly building and destroying the project will cause CertBot to fail, and each host can only register for a new certificate once every seven days.

```bash
terraform destroy 
```

# Test The Webmail Certificate

Replace the mail host and domain names with the names specified in the **payload.sh** script.

```bash
openssl s_client -connect mail.mWorks.tech:443 2>/dev/null </dev/null | \
  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
```

# Check The Certificate Expiry Date

```bash
openssl x509 -in /etc/letsencrypt/archive/mail.mworks.tech/fullchain1.pem -enddate -noout
```
