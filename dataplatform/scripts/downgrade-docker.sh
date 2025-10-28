#!/bin/bash
set -e

# ============================================================
# Docker downgrade/installation script
# Default: Docker 24.0.7 for Ubuntu 24.04 (noble)
# Usage:
#   ./downgrade_docker.sh [DOCKER_VERSION] [UBUNTU_CODENAME]
# Example:
#   ./downgrade_docker.sh 25.0.5 jammy
# ============================================================

DOCKER_VERSION="${1:-24.0.7}"
UBUNTU_CODENAME="${2:-noble}"
TMP_DIR="docker_${DOCKER_VERSION}_${UBUNTU_CODENAME}_install"

# === Map codename to Ubuntu version string used in Docker filenames ===
case "$UBUNTU_CODENAME" in
  focal) UBUNTU_VERSION="20.04" ;;
  jammy) UBUNTU_VERSION="22.04" ;;
  noble) UBUNTU_VERSION="24.04" ;;
  *)
    echo "Unsupported Ubuntu codename: $UBUNTU_CODENAME"
    echo "Valid values: focal (20.04), jammy (22.04), noble (24.04)"
    exit 1
    ;;
esac

echo "=============================================="
echo "Installing Docker ${DOCKER_VERSION} for Ubuntu ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"
echo "=============================================="

# === Stop Docker ===
echo ">>> Stopping Docker service..."
sudo systemctl stop docker || true

# === Remove existing Docker installation ===
echo ">>> Removing existing Docker packages..."
sudo apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true

# === Prepare directory ===
echo ">>> Creating temporary directory ${TMP_DIR}..."
rm -rf "${TMP_DIR}"
mkdir "${TMP_DIR}" && cd "${TMP_DIR}"

# === Build base URL for the target codename ===
BASE_URL="https://download.docker.com/linux/ubuntu/dists/${UBUNTU_CODENAME}/pool/stable/amd64"

# === Download packages ===
echo ">>> Downloading Docker ${DOCKER_VERSION} packages from ${BASE_URL} ..."
wget -q ${BASE_URL}/containerd.io_1.6.22-1_amd64.deb
wget -q ${BASE_URL}/docker-ce_${DOCKER_VERSION}-1~ubuntu.${UBUNTU_VERSION}~${UBUNTU_CODENAME}_amd64.deb
wget -q ${BASE_URL}/docker-ce-cli_${DOCKER_VERSION}-1~ubuntu.${UBUNTU_VERSION}~${UBUNTU_CODENAME}_amd64.deb

# Buildx/Compose plugins — these may not exist for older versions, so allow failure
wget -q ${BASE_URL}/docker-buildx-plugin_0.11.2-1~ubuntu.${UBUNTU_VERSION}~${UBUNTU_CODENAME}_amd64.deb || true
wget -q ${BASE_URL}/docker-compose-plugin_2.20.2-1~ubuntu.${UBUNTU_VERSION}~${UBUNTU_CODENAME}_amd64.deb || true

# === Install downloaded packages ===
echo ">>> Installing downloaded packages..."
sudo apt install -y ./*.deb

# === Prevent automatic upgrades ===
echo ">>> Holding Docker packages..."
sudo apt-mark hold docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true

# === Restart service ===
echo ">>> Restarting Docker service..."
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl restart docker

# === Clean up ===
echo ">>> Cleaning up temporary files..."
cd ..
rm -rf "${TMP_DIR}"

echo "Docker installation complete."
docker --version
