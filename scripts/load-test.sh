#!/usr/bin/env bash
#
# Simulates load on the web-frontend and api-server endpoints to trigger
# KEDA auto-scaling, then queries Container Apps to show replica counts.
#
# Usage:
#   ./load-test.sh --web-url <WEB_FRONTEND_URL> --resource-group <RG_NAME> \
#                  [--api-url <API_SERVER_URL>] [--requests 200] [--concurrency 20]

set -euo pipefail

WEB_URL=""
API_URL=""
RESOURCE_GROUP=""
REQUEST_COUNT=200
CONCURRENCY=20

while [[ $# -gt 0 ]]; do
    case "$1" in
        --web-url)       WEB_URL="$2"; shift 2 ;;
        --api-url)       API_URL="$2"; shift 2 ;;
        --resource-group) RESOURCE_GROUP="$2"; shift 2 ;;
        --requests)      REQUEST_COUNT="$2"; shift 2 ;;
        --concurrency)   CONCURRENCY="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$WEB_URL" || -z "$RESOURCE_GROUP" ]]; then
    echo "Usage: $0 --web-url <URL> --resource-group <RG> [--api-url <URL>] [--requests N] [--concurrency N]"
    exit 1
fi

send_load() {
    local url="$1"
    local label="$2"
    local total="$3"
    local concurrency="$4"

    echo ""
    echo "=== Sending $total requests to $label ($url) with concurrency $concurrency ==="

    local success=0
    local fail=0
    local sent=0

    while [[ $sent -lt $total ]]; do
        local batch_size=$concurrency
        if (( sent + batch_size > total )); then
            batch_size=$((total - sent))
        fi

        local pids=()
        for (( j=0; j<batch_size; j++ )); do
            (curl -s -o /dev/null -w "%{http_code}" --max-time 30 "$url" 2>/dev/null || echo "000") &
            pids+=($!)
        done

        for pid in "${pids[@]}"; do
            local code
            code=$(wait "$pid" 2>/dev/null) || code="000"
            if [[ "$code" =~ ^[23] ]]; then
                success=$((success + 1))
            else
                fail=$((fail + 1))
            fi
        done

        sent=$((sent + batch_size))
        echo "  Progress: $sent / $total (Success: $success, Failed: $fail)"
    done

    echo "  Completed: $success successful, $fail failed"
}

# --- Send load to web-frontend ---
send_load "${WEB_URL}/health" "web-frontend" "$REQUEST_COUNT" "$CONCURRENCY"

# --- Send load to api-server (if provided) ---
if [[ -n "$API_URL" ]]; then
    send_load "${API_URL}/health" "api-server" "$REQUEST_COUNT" "$CONCURRENCY"
fi

# --- Query replica counts ---
echo ""
echo "=== Waiting 30 seconds for scaling to take effect ==="
sleep 30

echo ""
echo "=== Current Container App Replica Counts ==="

app_names=$(az containerapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv 2>/dev/null || true)

if [[ -n "$app_names" ]]; then
    while IFS= read -r app_name; do
        replica_info=$(az containerapp revision list \
            --name "$app_name" \
            --resource-group "$RESOURCE_GROUP" \
            --query "[0].{Revision:name, Replicas:properties.replicas, Active:properties.active}" \
            -o json 2>/dev/null || echo "{}")

        replicas=$(echo "$replica_info" | grep -o '"Replicas":[0-9]*' | cut -d: -f2 || echo "?")
        revision=$(echo "$replica_info" | grep -o '"Revision":"[^"]*"' | cut -d'"' -f4 || echo "?")

        echo "  $app_name: $replicas replica(s) [Revision: $revision]"
    done <<< "$app_names"
else
    echo "  Could not query Container Apps. Ensure 'az login' is done and resource group is correct."
fi

echo ""
echo "Load test complete."
