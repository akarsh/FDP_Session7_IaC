# Terraform = "builds the kitchen". We say WHAT we want; it works out HOW.
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "= 4.6.0" # pinned: everyone gets the same behaviour
    }
  }
}

# null = Docker's normal socket. To override, use an ABSOLUTE path:
# export TF_VAR_docker_host="unix://$HOME/.docker/run/docker.sock"
variable "docker_host" {
  type    = string
  default = null
}
provider "docker" { host = var.docker_host }

# The "ingredient": a small Linux image with Python (Ansible needs it).
# python:3.12-slim, pinned by multi-architecture digest (Intel/AMD + Apple Silicon).
resource "docker_image" "base" {
  name         = "python:3.12-slim@sha256:4840d514c583a4d3d8cad3940e68dee6f0f6f3635c12fcd0a3d74c21a5b93a54"
  keep_locally = true # "destroy" keeps the image, so a rebuild is fast
}

# The "server": a container that stays alive and waits for Ansible.
resource "docker_container" "demo" {
  name     = "iac-demo"
  image    = docker_image.base.image_id
  command  = ["sleep", "infinity"]
  must_run = true
  ports {
    internal = 80
    external = 8080
    ip       = "127.0.0.1" # this computer only, not the network
  }
}
