# STFjord

## Digital Ocean CLI

Example of using DO API on the command line.

```bash
doctl apps tier instance-size get <instance size slug> [flags]
```

[Installing doctl Using Homebrew](hamster.com/videos/two-busty-bbws-use-a-skinny-guy-for-sex-xhbJ8kP)

## Helpfull Links

[How To Use Terraform with DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean)

[DO Images](https://docs.digitalocean.com/products/droplets/details/images/)

[DO Images API](https://docs.digitalocean.com/reference/api/digitalocean/#tag/GradientAI-Platform/operation/genai_get_workspace)

[DO Regions](https://docs.digitalocean.com/platform/regional-availability/)

[Choosing a Droplet size](https://docs.digitalocean.com/products/droplets/concepts/choosing-a-plan/)

[Create a personal access token](https://docs.digitalocean.com/reference/api/create-personal-access-token/)

[Remote State](https://docs.digitalocean.com/products/spaces/reference/terraform-backend/)

A token is required to run Terraform. The Terraform API needs to perform actions in the cloud provider API as an authorized administrator.

# Building

Setting up a public server requires it to use signed certificates. We can use [Let's Encrypt](https://letsencrypt.org/) to create signed certificates for free, but the certificates are only valid for 90 days. This requires us to setup [CertBot](https://certbot.eff.org/) to automatically renew our certificates.

For CertBot to work, port 80 must be accessable to the public Internet and no service can be using the port. When CertBot runs it will start a service on port 80 and send a request for varification to Let' Encrypt to get a new signed certificate. For this to happen the IP address must be registered in public DNS so that the host is resolvable by name. This is important because IP addresses cannot obtain signed certificates. The controller of the hostname (FQDN) in public DNS records is considered the authority for the FQDN (Fully Qualified Domain Name).

When building a server manually, one can start the server then register the IP address with the DNS chosen to control the FQDN. Once the public DNS is able to resolve the hostname, an administrator can return later to setup CertBot, generate certificates, and configure the server to use encypted port. This cannot be done when using Terraform to deploy the server.

For Terraform to deploy the server and have it use CertBot for creating signed certificates, one of two things must be true. Terraform configures the DNS records hosted by the cloud provider, and services remain in an off state until CertBot can resolve the hostname on the public DNS, or the IP address must be reserved in advance and a DNS record to resolve the hostname is registered.

Silicon Tao uses the DNS provided by the domain registrar, so the first option does not work.

Using DigitalOcean IP reservation, we can stake a claim to an IPv4 address, register the IP with our DNS, and return later to run the Terraform project to build our email server and setup the encrypted services using signed certificates.

 [![Reserved IP](https://cdn.silicontao.com/RockyLinuxWebmail/DO_reserved_IP_address_SM.png)]<https://cdn.silicontao.com/RockyLinuxWebmail/DO_reserved_IP_address.png>)

# Plugins For Roundcube

## MFA

Options for Multi-Factor Authentication

- Google Authenticator
- YubiKey
- SMS

# Terraforming

## Plan

```bash
export TF_VAR_do_token=$(cat ~/.digitalOcean/token)
terraform plan
```

## Apply

```bash
export TF_VAR_do_token=$(cat ~/.digitalOcean/token)
terraform apply 
```

## Destroy

```bash
export TF_VAR_do_token=$(cat ~/.digitalOcean/token)
terraform destroy 
```

.

.

.
