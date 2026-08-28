#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${LEMMINGS_NAMESPACE:-lemmings}"
RELEASE_NAME="${LEMMINGS_RELEASE:-harness-lemmings}"

echo "=== LEMMINGS SMOKE TEST ==="

NODE_PORT=$(kubectl get svc "$RELEASE_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
URL="http://localhost:${NODE_PORT}"

echo "Testing $URL ..."

for i in $(seq 1 10); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/healthz" 2>/dev/null || echo "000")
    if [ "$STATUS" = "200" ]; then
        echo "Health check: PASS"
        BODY=$(curl -s "$URL")
        if echo "$BODY" | grep -qi "lemmings"; then
            echo "Content check: PASS (LEMMINGS page served)"
            echo ""
            echo "Result: ALL TESTS PASSED"
            exit 0
        else
            echo "Content check: FAIL (page does not contain 'lemmings')"
            exit 1
        fi
    fi
    echo "  Attempt $i/10: status=$STATUS, retrying in 3s..."
    sleep 3
done

echo "Result: FAILED (service not responding after 30s)"
exit 1
