# Setup Fedora 40 dev env with Ansible

Setup Fedora 40 Desktop with NVIDIA GPU passthrough.

## Install ansible
`sudo dnf -y install ansible`

## Clone repo
`git clone https://github.com/mikkott/setup-dev-env.git`

# Run Ansible playbook
`ansible-playbook ansible/playbooks/main.yml -e ansible_user=$(whoami)`