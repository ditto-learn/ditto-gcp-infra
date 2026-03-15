# ditto-gcp-infra

Infrastructure ownership repo for Ditto.

## Ownership

- Terraform modules and component configurations
- Terraform CI workflows
- Shared runtime and platform provisioning for Ditto services

## Terraform Entry Point

Use only the component roots under terraform:

- terraform/platform
- terraform/database
- terraform/runtime

Legacy monolithic root Terraform files were intentionally removed.

See terraform/README.md for architecture, state layout, and commands.
