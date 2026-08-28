#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${LEMMINGS_NAMESPACE:-lemmings}"
RELEASE_NAME="${LEMMINGS_RELEASE:-harness-lemmings}"
IMAGE_NAME="${LEMMINGS_IMAGE:-harness-lemmings}"

echo "=== TEARING DOWN LEMMINGS ==="

# Uninstall Helm release
echo "[1/3] Uninstalling Helm release..."
helm uninstall "$RELEASE_NAME" --namespace "$NAMESPACE" 2>/dev/null || echo "  (already removed)"

# Delete namespace
echo "[2/3] Deleting namespace '$NAMESPACE'..."
kubectl delete namespace "$NAMESPACE" --ignore-not-found

# Remove local image
echo "[3/3] Removing local image..."
docker rmi "$IMAGE_NAME:latest" 2>/dev/null || true

echo ""
echo "=== THE LEMMINGS HAVE BEEN NUKED ==="
