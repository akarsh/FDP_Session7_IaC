# Demo script: Session 7, Infrastructure as Code (10-12-2026, 6:00-7:30 PM)

**Status: not run end to end.** The build environment had no Docker or Terraform. The playbook was syntax-checked and the template and `creates:` behaviour were tested locally with ansible-core 2.17.14. Do one full dry run yourself the day before. See ASSUMPTIONS.md.

## 1. Versions (pinned in the files)

| Tool | Version | Where pinned |
|---|---|---|
| Terraform | 1.17.1 current when checked (>= 1.9.0 required) | `required_version` in `main.tf` |
| Terraform provider kreuzwerker/docker | 4.6.0 | `main.tf` |
| ansible-core | 2.17.14 | `requirements.txt` |
| Ansible collection community.docker | 5.4.0 | `requirements.yml` |
| Image | python:3.12-slim, multi-arch index digest `sha256:4840d514...3a54` | `main.tf` |

The Docker CLI and daemon (Docker Desktop or Engine) must be installed. The `community.docker.docker` connection uses the **docker CLI**; the Python Docker SDK is not needed for this demo.

## 2. Setup checklist (do the day before)

**macOS / Linux**
1. Install Docker Desktop (macOS) or Docker Engine (Linux); start it; `docker ps` works.
2. Install Terraform (`terraform version`).
3. Change directory to `demo` and then execute `python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`
4. `ansible-galaxy collection install -r requirements.yml`
5. `docker pull python:3.12-slim`
6. In `demo/`: `terraform init` (this creates `.terraform.lock.hcl`; keep it with the folder).
7. Dry run: `terraform apply -auto-approve`, `ansible-playbook -i inventory.ini playbook.yml` twice, open http://localhost:8080, then `terraform destroy -auto-approve`.

**Windows**: Ansible's control node does not run natively on Windows. Use WSL2 (Ubuntu) with Docker Desktop's WSL integration enabled, then follow the Linux steps inside WSL. Not tested.

**Docker socket**: Terraform uses Docker's default socket. If it is not found, set an absolute path:
- Linux / WSL2: `export TF_VAR_docker_host="unix:///var/run/docker.sock"`
- macOS Docker Desktop (if needed): `export TF_VAR_docker_host="unix://$HOME/.docker/run/docker.sock"`
- Use `$HOME`, not `~` (the tilde is not expanded inside quotes).

Both the override and the default were not tested.

## 3. Live demo (slides 16-20)

Run everything from the `demo/` folder.

| Step | Command | What to see |
|---|---|---|
| 1 Build | `terraform init` then `terraform apply` | `Apply complete! Resources: 2 added, 0 changed, 0 destroyed.`; `docker ps` lists `iac-demo` |
| 2 Set up | `ansible-playbook -i inventory.ini playbook.yml` | tasks show `changed`; http://localhost:8080 shows "Hello from Session 7" |
| 3 Run again | same command | `changed=0` in the PLAY RECAP |
| 4 Change one line | edit `greeting:` in `playbook.yml` to "Hello from YOC Berlin"; same command | only the page task is `changed` (`changed=1`); refresh the browser |
| 5 Rebuild | `terraform destroy`, `terraform apply`, `ansible-playbook ...` or `./rebuild.sh` | same page is back |

`rebuild.sh` stops at the first failure and prints the failing command and line number.

If step 3 does not show `changed=0`, check which task changed (most likely the package-list refresh or the nginx start). That is the first thing to fix in the dry run.

## 4. If the live demo fails

Jump to the backup slides (29-34). They use the same commands. The output shown there is an example of the format, not a captured run; replace it with your own screenshots after the dry run.

## 5. Slide-by-slide timing (sums to 90 minutes; backup slides excluded)

| Slides | Topic | Minutes | Clock |
|---|---|---|---|
| 1 | Title | 1 | 0:00-0:01 |
| 2 | Agenda | 2 | 0:01-0:03 |
| 3 | Plan and the one example | 2 | 0:03-0:05 |
| 4 | The problem: setup by hand | 6 | 0:05-0:11 |
| 5 | Pair and share | 4 | 0:11-0:15 |
| 6 | Recipe card idea | 8 | 0:15-0:23 |
| 7 | Steps vs result | 7 | 0:23-0:30 |
| 8 | Two jobs | 2 | 0:30-0:32 |
| 9 | Terraform | 3 | 0:32-0:35 |
| 10 | Ansible | 3 | 0:35-0:38 |
| 11 | Our example in one picture | 2 | 0:38-0:40 |
| 12 | Break | 5 | 0:40-0:45 |
| 13 | Demo plan | 2 | 0:45-0:47 |
| 14 | Reading main.tf | 4 | 0:47-0:51 |
| 15 | Reading playbook.yml | 4 | 0:51-0:55 |
| 16-20 | Demo steps 1-5 | 15 | 0:55-1:10 |
| 21 | What just happened | 3 | 1:10-1:13 |
| 22 | Four good habits | 4 | 1:13-1:17 |
| 23 | Bigger kitchen | 3 | 1:17-1:20 |
| 24 | Recap | 2 | 1:20-1:22 |
| 25 | Quiz | 3 | 1:22-1:25 |
| 26 | Homework | 2 | 1:25-1:27 |
| 27 | Watch and read next | 1 | 1:27-1:28 |
| 28 | Questions and Thank you | 2 | 1:28-1:30 |

## 6. Quiz answer key (slide 25)

1. **Terraform** builds the server. Ansible sets up what is inside it.
2. **changed=0**: everything was already as described, so nothing was changed (idempotence).
3. **Not in the files.** Keep passwords and keys in a safe place such as a secrets manager or protected environment variables.

## 7. Homework (slide 26), about 20 minutes

1. Change `greeting` in `playbook.yml` to your name and department.
2. Add a `<p>` line to `templates/index.html.j2`.
3. Run `./rebuild.sh` and open http://localhost:8080.
4. Bonus: change the external port from 8080 to 8081 in `main.tf`; run `terraform plan` and read what it says (the container must be replaced).

## 8. References used in the deck (all opened and confirmed)

IBM Technology (YouTube; video lengths could not be confirmed):
- Terraform Explained: https://www.youtube.com/watch?v=HmxkYNv1ksg
- Ansible vs. Terraform: What's the difference?: https://www.youtube.com/watch?v=rx4Uh3jv1cA
- What is Ansible? (description lists 2:07 config management, 3:29 playbook, 6:22 agent-less, 7:53 idempotent): https://www.youtube.com/watch?v=fHO1X93e4WA

Books:
- Terraform: Up and Running, 3rd Ed., Yevgeniy Brikman, O'Reilly, 2022: https://www.oreilly.com/library/view/terraform-up-and/9781098116736/
- Ansible: Up and Running, 3rd Ed., Meijer, Hochstein, Moser, O'Reilly, 2022: https://www.oreilly.com/library/view/ansible-up-and/9781098109141/
- Terraform in Action, Scott Winkler, Manning, 2021: https://www.manning.com/books/terraform-in-action
