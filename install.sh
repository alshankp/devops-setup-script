#!/bin/bash
set -e

echo "🚀 Starting DevOps environment setup on your local Ubuntu system..."

install_common_tools() {
  echo "🔧 Installing essential CLI tools..."
  sudo apt update
  sudo apt install -y \
    curl \
    wget \
    git \
    zsh \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
}

install_python_latest() {
  echo "🐍 Installing Python 3.12 and pip..."
  sudo add-apt-repository ppa:deadsnakes/ppa -y
  sudo apt update
  sudo apt install -y python3.12 python3.12-venv python3.12-dev python3-pip
  sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
}

install_node_latest() {
  echo "🟩 Installing latest Node.js (LTS)..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
}

install_docker_latest() {
  echo "🐳 Installing Docker and Docker Compose..."
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
}

install_ansible_latest() {
  echo "🛠️ Installing Ansible..."
  sudo add-apt-repository --yes --update ppa:ansible/ansible
  sudo apt install -y ansible
}

install_terraform_latest() {
  echo "🌍 Installing latest Terraform..."
  TMP_DIR=$(mktemp -d)
  cd "$TMP_DIR"
  LATEST_URL=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest \
    | grep "browser_download_url.*linux_amd64.zip" | cut -d '"' -f 4)
  curl -Lo terraform.zip "$LATEST_URL"
  unzip terraform.zip
  chmod +x terraform
  sudo mv terraform /usr/local/bin/
  cd -
  rm -rf "$TMP_DIR"
}

install_vscode_latest() {
  if command -v xdg-open >/dev/null; then
    echo "📝 Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
    rm microsoft.gpg
  else
    echo "🚫 VS Code skipped (no GUI detected)"
  fi
}

verify_versions() {
  echo -e "\n🔍 Verifying installed tool versions..."
  declare -A tools=(
    ["Docker"]="docker"
    ["Docker Compose"]="docker compose"
    ["Ansible"]="ansible"
    ["Terraform"]="terraform"
    ["Python"]="python3"
    ["Pip"]="pip3"
    ["Node.js"]="node"
    ["npm"]="npm"
    ["Git"]="git"
    ["Zsh"]="zsh"
    ["Unzip"]="unzip"
  )

  for name in "${!tools[@]}"; do
    echo -n "$name: "
    ${tools[$name]} --version 2>/dev/null || echo "❌ Not installed"
  done
}

main() {
  install_common_tools
  install_python_latest
  install_node_latest
  install_docker_latest
  install_ansible_latest
  install_terraform_latest
  install_vscode_latest
  verify_versions

  echo -e "\n✅ All DevOps tools installed successfully!"
  echo "🔁 Please log out and log in again or reboot to enable Docker permissions for your user."
}

main
