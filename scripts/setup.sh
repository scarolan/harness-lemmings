#!/usr/bin/env bash
set -euo pipefail

# Setup script for harness-lemmings
# Prerequisites: kubectl, helm, docker (or nerdctl)

NAMESPACE="${LEMMINGS_NAMESPACE:-lemmings}"
RELEASE_NAME="${LEMMINGS_RELEASE:-harness-lemmings}"
IMAGE_NAME="${LEMMINGS_IMAGE:-harness-lemmings}"
IMAGE_TAG="${LEMMINGS_TAG:-latest}"

echo "=== HARNESS LEMMINGS SETUP ==="
echo "Namespace:  $NAMESPACE"
echo "Release:    $RELEASE_NAME"
echo "Image:      $IMAGE_NAME:$IMAGE_TAG"
echo ""

# Build the container image
echo "[1/3] Building LEMMINGS container image..."
docker build -t "$IMAGE_NAME:$IMAGE_TAG" app/

# Create namespace if needed
echo "[2/3] Creating namespace '$NAMESPACE'..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Deploy with Helm
echo "[3/3] Deploying LEMMINGS via Helm..."
helm upgrade --install "$RELEASE_NAME" helm/harness-lemmings \
  --namespace "$NAMESPACE" \
  --set image.repository="$IMAGE_NAME" \
  --set image.tag="$IMAGE_TAG" \
  --set namespace="$NAMESPACE" \
  --wait --timeout 60s

echo ""
echo "=== LEMMINGS IS DEPLOYED ==="
echo ""
NODE_PORT=$(kubectl get svc "$RELEASE_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
echo "Access LEMMINGS at: http://localhost:${NODE_PORT}"
echo ""
echo "Oh no!"
