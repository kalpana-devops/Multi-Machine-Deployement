#!/usr/bin/env bash
# ============================================================
# Run this ON node01.
# Sets node01 up as BOTH:
# 1. An NFS server exporting /srv/nfs/redis-data
# 2. A local Docker image registry on port 5000
#
# Idempotent: safe to re-run.
# ============================================================
set -euo pipefail
# Adjust this to match your lab's actual subnet if the default is too
# narrow/wide for your environment (e.g. KodeKloud playgrounds are
# usually on a 10.x.x.x range).
NFS_CLIENT_CIDR="${NFS_CLIENT_CIDR:-10.0.0.0/8}"
EXPORT_DIR="/srv/nfs/redis-data"
echo ">> [1/4] Installing nfs-kernel-server..."
sudo apt-get update -qq
sudo apt-get install -y -qq nfs-kernel-server
echo ">> [2/4] Creating and exporting ${EXPORT_DIR} to ${NFS_CLIENT_CIDR} ..."
sudo mkdir -p "${EXPORT_DIR}"
sudo chown nobody:nogroup "${EXPORT_DIR}"
sudo chmod 777 "${EXPORT_DIR}"
EXPORT_LINE="${EXPORT_DIR} ${NFS_CLIENT_CIDR}(rw,sync,no_subtree_check,no_root_squash)"
if ! grep -qF "${EXPORT_DIR}" /etc/exports 2>/dev/null; then
echo "${EXPORT_LINE}" | sudo tee -a /etc/exports > /dev/null
fi
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server
sudo systemctl enable nfs-kernel-server --quiet
echo ">> [3/4] Starting local Docker registry on port 5000 ..."
if [ "$(docker inspect -f '{{.State.Running}}' registry 2>/dev/null || true)" != "true" ]; then
docker rm -f registry >/dev/null 2>&1 || true
docker run -d \
--name registry \
--restart=always \
-p 5000:5000 \
-v registry-data:/var/lib/registry \
registry:2
else
echo " (registry container already running)"
fi
echo ">> [4/4] Done."
NODE01_IP="$(hostname -I | awk '{print $1}')"
echo ""
echo "node01 is ready:"
echo " - NFS export: ${NODE01_IP}:${EXPORT_DIR}"
echo " - Docker registry: ${NODE01_IP}:5000"
echo ""
echo "On controlplane, run:"
echo " ./controlplane-setup.sh ${NODE01_IP}"
