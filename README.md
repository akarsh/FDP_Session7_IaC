# Infrastructure as Code: Terraform and Ansible Demo

This repository contains a small Infrastructure as Code demo for a Session 7
presentation. Terraform creates a Docker container; Ansible configures it to
serve a greeting page with nginx. The container publishes the page at
<http://localhost:8080> and binds only to localhost.

## Repository contents

- [`demo/main.tf`](demo/main.tf) — Docker provider, pinned base image, and container.
- [`demo/playbook.yml`](demo/playbook.yml) — installs nginx, deploys the page, and starts the web server.
- [`demo/inventory.ini`](demo/inventory.ini) — Ansible inventory using the Docker connection.
- [`demo/templates/index.html.j2`](demo/templates/index.html.j2) — HTML page template.
- [`demo/rebuild.sh`](demo/rebuild.sh) — destroys and recreates the container, then configures it.
- [`demo/requirements.txt`](demo/requirements.txt) and [`demo/requirements.yml`](demo/requirements.yml) — pinned Ansible dependencies.
- [`demo_script.md`](demo_script.md) — presentation run-through and timing.
- [`ASSUMPTIONS.md`](ASSUMPTIONS.md) — tested behavior and items that still need verification.

## Requirements

- Docker Desktop or Docker Engine, running and accessible through the `docker` CLI.
- Terraform 1.9.0 or later. The Docker provider is pinned to 4.6.0.
- Python 3 and Ansible. The demo pins `ansible-core` to 2.17.14 and the
  `community.docker` collection to 5.4.0.

Ansible's control node is not supported natively on Windows; use WSL2 with
Docker Desktop's WSL integration.

## Setup

Run these commands from the repository root:

```sh
cd demo
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
terraform init
```

`terraform init` creates `demo/.terraform.lock.hcl`. Keep this lock file with
the project so Terraform can use the resolved provider version.

If Terraform cannot find the Docker socket, set `TF_VAR_docker_host` to the
absolute socket path for your system before running Terraform. For example:

```sh
# macOS Docker Desktop, if needed
export TF_VAR_docker_host="unix://$HOME/.docker/run/docker.sock"

# Linux or WSL2
export TF_VAR_docker_host="unix:///var/run/docker.sock"
```

## Run the demo

From `demo/`, create the container and configure it:

```sh
terraform apply
ansible-playbook -i inventory.ini playbook.yml
```

Open <http://localhost:8080> to see the page. Run the Ansible command again to
observe the playbook's intended idempotent behavior. Change the `greeting`
variable in `playbook.yml` and run Ansible again to update the page.

To destroy and recreate the container, then configure it again, run either:

```sh
./rebuild.sh
```

or run `terraform destroy`, `terraform apply`, and the Ansible command above
separately. The Docker image is configured to remain locally after Terraform
destroy.

When finished, remove the Terraform-managed container with:

```sh
terraform destroy
```

## Verification status

The playbook syntax and selected Ansible behavior were checked locally, but the
full demo has not been run end to end with Docker and Terraform. Review
[`ASSUMPTIONS.md`](ASSUMPTIONS.md) before presenting, and do a complete dry run
in the target environment.
