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

A token is required to run Terraform. The Terraform API needs to perform actions in the cloud provider API as an authorized administrator.

# Building

Terraform --var_file=./settings.json --token=~/.digitalOcean/tokenOne

# Plugins For Roundcube

## MFA

Options for Multi-Factor Authentication

- Google Authenticator
- YubiKey
- SMS

# Terraforming

## Plan

```bash
terraform plan -var do_token=$(cat ~/.digitalOcean/token) -var pvt_key=~/.ssh/id_ecdsa
```
