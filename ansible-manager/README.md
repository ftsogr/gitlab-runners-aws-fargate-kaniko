# Ansible Playbook to Configure GitLab Runner on EC2 Instances

This playbook configures **GitLab Runner** on EC2 instances, installs necessary dependencies, and registers the runner with a GitLab project. The process is broken down into two primary roles: runner_manager_setup for setting up the runner environment and runner_registration for registering the GitLab Runner.

## Prerequisites

Before running the playbook, ensure the following:

- You have an **AWS EC2** instance set up.
- You have a **GitLab Personal Access Token** with the necessary permissions to register runners.
- You added **SSH Private Key** (located in AWS Secrets Manager) under `~/ftso/clients/ssh-runner-manager.pem` and configured permissions.
- Ansible installed on your local machine.
- Ansible Vault can be used to securely store sensitive data like access tokens.

### Required Variables

You can define the `access_token` variable in the cli using the flag `extra-vars`, like this: `--extra-vars "access_token=<TOKEN>"` or add it in the secrets.yml file.

You will need to define the following variables in the `inventories/main/host_vars/manager1` file:

- **name**: The name and tag of the GitLab Runner.
- **project_id**: The GitLab project ID where the runner will be registered.
- **limit**: The limit of the concurrent jobs that can run for the specific runner.
- **cluster**: The name of your ECS Cluster.
- **task**: The name of the task definition you are associating with this runner.

## Installation

### 1. Install Dependencies
Install the necessary Ansible collections (IMPORTANT: You need to have community.general v10.2.0 or later):
```bash
ansible-galaxy collection install community.general
```
### 2. Create Ansible Vault File (Optional)
For sensitive information like access_token. It is recommended to use Ansible Vault:
```bash
ansible-vault create secrets.yml
```
Add the required variables in the secrets.yml file in YAML format:
```bash
access_token: "your_personal_access_token"
```
### 3. Define Runners in Inventory
Make sure to update `manager1.yml` with a new runner under the `runners` key like this :
```
  - name: "<name>"
    project_id: <id>
    limit: <limit>
    cluster: "<cluster>"
    task: "<task>"
```
### 4.Usage
To run specific role based tasks:
```
ansible-playbook playbooks/main.yml -i inventories/main/hosts --tag "<TAG>" --extra-vars "access_token=<TOKEN>"
```
To dry-run specific role based tasks:
```
ansible-playbook playbooks/main.yml -i inventories/main/hosts --tag "<TAG>" --extra-vars "access_token=<TOKEN>" --check
```

####  Tasks Performed by the Playbook
- **runner_manager_setup** role:
  - **Install and update necessary tools**: It installs the necessary packages like gitlab-runner, python3-pip, python3-gitlab, python3-requests and Fargate Driver.

- **runner_registration** role:
  - **Configure GitLab Runner**: Registers the GitLab Runner to the specified GitLab project. Configures the runner with a custom configuration file template.
  - **Configure Fargate**: Applies a custom configuration for Fargate using the provided template.
  - **Verify Runner Configuration**: Verifies the GitLab Runner configuration to ensure everything is set up correctly.

#### Template Files
- **templates/runner_config.j2**: Template for configuring the GitLab runner.
- **templates/fargate_config.j2**: Template for configuring Fargate-specific settings for the GitLab Runner.
## Related Projects

This playbook assumes AWS infrastructure (such as VPCs and subnets) is already provisioned.
You can set up the required AWS environment using the [gitlab-aws-deployment](https://github.com/ftsogr/gitlab-aws-deployment) repository.
