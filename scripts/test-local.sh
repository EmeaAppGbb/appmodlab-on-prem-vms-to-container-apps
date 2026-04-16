#!/usr/bin/env bash
# test-local.sh - Test all PawsCare service endpoints locally
# Usage: ./scripts/test-local.sh
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost}"
API_PORT="${API_PORT:-8381}"
WEB_PORT="${WEB_PORT:-8380}"

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  ✅ PASS: $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  ❌ FAIL: $1 - $2"; }

test_endpoint() {
    local name="$1"
    local url="$2"
    local expected="${3:-200}"

    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null) || status="000"
    if [ "$status" = "$expected" ]; then
        pass "$name (HTTP $status)"
    else
        fail "$name" "expected HTTP $expected, got $status"
    fi
}

test_json_field() {
    local name="$1"
    local url="$2"
    local field="$3"
    local expected="$4"

    body=$(curl -s --max-time 10 "$url" 2>/dev/null) || body=""
    value=$(echo "$body" | grep -o "\"$field\":\"[^\"]*\"" | head -1 | cut -d'"' -f4)
    if [ "$value" = "$expected" ]; then
        pass "$name ($field=$value)"
    else
        fail "$name" "expected $field='$expected', got '$value'"
    fi
}

echo ""
echo "=========================================="
echo "  PawsCare Local Container Test Suite"
echo "=========================================="
echo ""

# --- API Server Tests ---
echo "🔹 API Server (${BASE_URL}:${API_PORT})"
echo "-------------------------------------------"
test_endpoint "API health endpoint" "${BASE_URL}:${API_PORT}/health"
test_json_field "API health status" "${BASE_URL}:${API_PORT}/health" "status" "healthy"
test_endpoint "API root endpoint" "${BASE_URL}:${API_PORT}/"
test_endpoint "Patients API (GET)" "${BASE_URL}:${API_PORT}/api/patients"
test_endpoint "Appointments API (GET)" "${BASE_URL}:${API_PORT}/api/appointments"
test_endpoint "Prescriptions API (GET)" "${BASE_URL}:${API_PORT}/api/prescriptions"
test_endpoint "Lab Results API (GET)" "${BASE_URL}:${API_PORT}/api/labresults"
echo ""

# --- Web Frontend Tests ---
echo "🔹 Web Frontend (${BASE_URL}:${WEB_PORT})"
echo "-------------------------------------------"
test_endpoint "Web frontend root" "${BASE_URL}:${WEB_PORT}/"
test_endpoint "Web frontend health" "${BASE_URL}:${WEB_PORT}/health"
echo ""

# --- Docker Health Status ---
echo "🔹 Docker Container Health"
echo "-------------------------------------------"
for svc in api-server background-worker web-frontend; do
    health=$(docker compose ps --format json 2>/dev/null | grep -o "\"$svc\"[^}]*\"Health\":\"[^\"]*\"" | grep -o '"Health":"[^"]*"' | cut -d'"' -f4) || health="unknown"
    if [ "$health" = "healthy" ]; then
        pass "Container $svc is healthy"
    else
        fail "Container $svc" "health=$health"
    fi
done
echo ""

# --- Summary ---
TOTAL=$((PASSED + FAILED))
echo "=========================================="
echo "  Results: $PASSED/$TOTAL passed, $FAILED failed"
echo "=========================================="
echo ""

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
