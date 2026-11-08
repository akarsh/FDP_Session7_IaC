#!/usr/bin/env bash
# One script, three steps: destroy -> build -> configure.
# Works from any folder; stops at the first failure and says which command failed.
set -euo pipefail
trap 'echo "ERROR: this command failed: $BASH_COMMAND (line $LINENO)" >&2' ERR

cd "$(dirname "$0")"

terraform destroy -auto-approve
terraform apply -auto-approve
ansible-playbook -i inventory.ini playbook.yml

echo "Done. Open http://localhost:8080"
