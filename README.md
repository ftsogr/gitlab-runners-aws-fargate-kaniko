# GitLab CI Runners on Fargate Spot with Kaniko

This guide builds a secure, scalable, and cost-effective CI runner setup using:

- **GitLab CE** deployed at `gitlab.ftso.gr`
- **ARM EC2 Manager** to register and launch jobs
- **AWS Fargate (Spot)** for running CI jobs
- **Kaniko** for unprivileged Docker builds

---

## 🔧 What This Deploys

- **Fargate Infrastructure** (Terraform)
- **GitLab Runner Manager** on EC2 ARM (Ansible)
- **Kaniko Docker Image** (Dockerfile)
- **CI Project Example** (GitLab `.gitlab-ci.yml`)

---

## 📁 Folder-by-Folder Usage

| Step | Directory         | Description                                 |
|------|-------------------|---------------------------------------------|
| 01   | `terraform/`       | Deploys ECS cluster and roles               |
| 02   | `ansible-manager/` | Configures EC2 ARM runner                   |
| 03   | `kaniko-image/`    | Dockerfile for Kaniko container builds     |
| 04   | `example-project/` | Sample pipeline using Kaniko in CI         |

---

## 🧰 Prerequisites

- ✅ GitLab server reachable at `https://gitlab.ftso.gr`
- ✅ Admin token or group runner registration token
- ✅ SSH access to EC2 manager (`ansible_host = manager`)
- ✅ Docker registry access (e.g., ECR)

---

## 🔐 GitLab Manual Setup

1. Log in to `https://gitlab.ftso.gr`
2. Go to **Admin > CI/CD > Runners**
3. Copy the **registration token**
4. Store in `group_vars/all.yml`:
```yaml
gitlab_url: "https://gitlab.ftso.gr"
registration_token: "PASTE_REPLACE_WITH_YOUR_GITLAB_RUNNER_TOKEN"

Note: `gitlab_url` should point to the internal private IP of your GitLab server, e.g., `http://10.0.3.5`, from the original VPC deployment.
```

---

## 🚀 Setup Instructions

### 1️⃣ Provision Fargate Runner Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

Creates:
- ECS cluster
- IAM execution roles
- Task definition template
- CloudWatch log groups

---

### 2️⃣ Configure ARM Manager EC2 with Ansible

```bash
cd ansible-manager
ansible-playbook -i inventories/hosts playbooks/main.yml
```

This installs GitLab Runner and registers it to use Fargate as the custom executor.

---

### 3️⃣ Build and Push Kaniko Image

```bash
cd kaniko-image
docker build -t ftso/kaniko-runner .
docker push ftso/kaniko-runner:latest
```

---

### 4️⃣ Run Pipeline with Example Project

```yaml
# .gitlab-ci.yml
image: ftso/kaniko-runner:latest

build:
  script:
    - echo "🛠 Building inside Kaniko on Fargate"
```

Place this file in any GitLab project to trigger the workflow.

---

## ✅ Validation Checklist

- [ ] Runner registered in GitLab at `https://gitlab.ftso.gr/admin/runners`
- [ ] CI pipeline triggers a Fargate task
- [ ] CloudWatch logs show Kaniko running
- [ ] Image is pushed to your registry
- [ ] Task stops after job completes

---

## 🌐 IMPORTANT: Set Your GitLab Domain First

This project uses `gitlab.ftso.gr` as an example.

🛠️ Before running any step, replace all references to this domain with your actual GitLab domain:

- `ansible-manager/group_vars/all.yml`
- `terraform/variables.tf`
- Any Docker image references or GitLab tokens

Example replacement:

```yaml
gitlab_url: "https://your.gitlab.domain"
```

---

## 👏 Credits 

Kudos to the **Logicea DevOps Team**  
🌐 Visit [logicea.com](https://logicea.com) for more.

---

## 🧑‍💻 Contributors
- [Demetris Diamantis](https://github.com/ftsogr)
- [Nick Bouris](https://www.linkedin.com/in/nbrs/)
- [Georgios Zoutis](https://github.com/Necrokefalos)
- [Panagiotis Stavrinakis](https://github.com/pan0sSt)
- [Panagiotis Tzaferos](https://github.com/ptzaf)


