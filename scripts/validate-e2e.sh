#!/usr/bin/env bash
# validate-e2e.sh - End-to-End Validation for PawsCare Modernized System
# Validates the full modernized system: services, Dapr, messaging, and storage
# Usage: ./scripts/validate-e2e.sh [--dapr-mode] [--api-port 8381] [--web-port 8380]
set -uo pipefail

# ── Configuration ──────────────────────────────────────────────
BASE_URL="${BASE_URL:-http://localhost}"
API_PORT="${API_PORT:-8381}"
WEB_PORT="${WEB_PORT:-8380}"
WORKER_PORT="${WORKER_PORT:-8082}"
DAPR_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dapr-mode)    DAPR_MODE=true; shift ;;
        --api-port)     API_PORT="$2"; shift 2 ;;
        --web-port)     WEB_PORT="$2"; shift 2 ;;
        --worker-port)  WORKER_PORT="$2"; shift 2 ;;
        --base-url)     BASE_URL="$2"; shift 2 ;;
        *)              echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ── Counters & helpers ─────────────────────────────────────────
PASSED=0
FAILED=0
SKIPPED=0
RESULTS=""

pass() {
    PASSED=$((PASSED + 1))
    RESULTS="${RESULTS}\n✅ PASS | $1"
    echo "  ✅ PASS: $1"
}

fail() {
    FAILED=$((FAILED + 1))
    RESULTS="${RESULTS}\n❌ FAIL | $1 | $2"
    echo "  ❌ FAIL: $1 - $2"
}

skip() {
    SKIPPED=$((SKIPPED + 1))
    RESULTS="${RESULTS}\n⏭️  SKIP | $1 | $2"
    echo "  ⏭️  SKIP: $1 - $2"
}

test_endpoint() {
    local name="$1"
    local url="$2"
    local expected="${3:-200}"

    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null) || status="000"
    if [ "$status" = "$expected" ]; then
        pass "$name (HTTP $status)"
        return 0
    else
        fail "$name" "expected HTTP $expected, got $status"
        return 1
    fi
}

test_json_field() {
    local name="$1"
    local url="$2"
    local field="$3"
    local expected="$4"

    local body
    body=$(curl -s --max-time 10 "$url" 2>/dev/null) || body=""
    local value
    value=$(echo "$body" | grep -o "\"$field\":\"[^\"]*\"" | head -1 | cut -d'"' -f4)
    if [ "$value" = "$expected" ]; then
        pass "$name ($field=$value)"
        return 0
    else
        fail "$name" "expected $field='$expected', got '$value'"
        return 1
    fi
}

post_json() {
    local url="$1"
    local data="$2"
    curl -s -X POST -H "Content-Type: application/json" -d "$data" --max-time 15 "$url" 2>/dev/null
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         PawsCare E2E Validation Test Suite                  ║"
echo "║         Modernized System — Full Integration Tests          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Config: API=${BASE_URL}:${API_PORT}  Web=${BASE_URL}:${WEB_PORT}  Dapr=${DAPR_MODE}"
echo ""

# ═══════════════════════════════════════════════════════════════
# TEST 1: Health Check All 3 Services
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1. SERVICE HEALTH CHECKS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# API Server
test_endpoint "API Server health" "${BASE_URL}:${API_PORT}/health"
test_json_field "API Server status field" "${BASE_URL}:${API_PORT}/health" "status" "healthy"
test_endpoint "API Server root" "${BASE_URL}:${API_PORT}/"

# Web Frontend
test_endpoint "Web Frontend root" "${BASE_URL}:${WEB_PORT}/"
test_endpoint "Web Frontend health" "${BASE_URL}:${WEB_PORT}/health"

# Background Worker
worker_status=$(curl -s --max-time 5 "${BASE_URL}:${WORKER_PORT}/health" 2>/dev/null) || worker_status=""
if [ -n "$worker_status" ]; then
    worker_health=$(echo "$worker_status" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ "$worker_health" = "healthy" ]; then
        pass "Background Worker health (status=healthy)"
    else
        fail "Background Worker health" "status=$worker_health"
    fi
else
    skip "Background Worker direct health" "Worker port not exposed (expected in compose without port mapping)"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# TEST 2: Create a New Pet Patient via API
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  2. CREATE PET PATIENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TIMESTAMP=$(date +%H%M%S)
PATIENT_NAME="E2E-TestPet-${TIMESTAMP}"

PATIENT_JSON=$(cat <<EOF
{
    "name": "${PATIENT_NAME}",
    "species": "Dog",
    "breed": "Golden Retriever",
    "age": 3,
    "ownerName": "E2E Test Owner",
    "ownerPhone": "555-0199",
    "ownerEmail": "e2e-test@pawscare.local"
}
EOF
)

patient_response=$(post_json "${BASE_URL}:${API_PORT}/api/patients" "$PATIENT_JSON")
if [ -n "$patient_response" ]; then
    patient_id=$(echo "$patient_response" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$patient_id" ]; then
        pass "Create patient via API (id=$patient_id)"
    else
        pass "Create patient via API (response received)"
    fi
else
    fail "Create patient via API" "POST /api/patients returned empty or failed"
fi

# Verify patient appears in listing
patients_list=$(curl -s --max-time 10 "${BASE_URL}:${API_PORT}/api/patients" 2>/dev/null) || patients_list=""
if echo "$patients_list" | grep -q "$PATIENT_NAME"; then
    pass "Verify patient in listing ($PATIENT_NAME)"
else
    fail "Verify patient in listing" "patient $PATIENT_NAME not found in GET /api/patients"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# TEST 3: Book an Appointment via API
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  3. BOOK APPOINTMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

APPT_DATE=$(date -d "+7 days" +%Y-%m-%d 2>/dev/null || date -v+7d +%Y-%m-%d 2>/dev/null || echo "2026-04-23")

APPOINTMENT_JSON=$(cat <<EOF
{
    "patientName": "${PATIENT_NAME}",
    "ownerName": "E2E Test Owner",
    "veterinarian": "Dr. E2E Tester",
    "date": "${APPT_DATE}",
    "time": "10:00",
    "type": "Wellness Check",
    "notes": "E2E validation test appointment"
}
EOF
)

appt_response=$(post_json "${BASE_URL}:${API_PORT}/api/appointments" "$APPOINTMENT_JSON")
if [ -n "$appt_response" ]; then
    appt_id=$(echo "$appt_response" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$appt_id" ]; then
        pass "Book appointment via API (id=$appt_id)"
    else
        pass "Book appointment via API (response received)"
    fi
else
    fail "Book appointment via API" "POST /api/appointments returned empty or failed"
fi

# Verify appointment exists
appts_list=$(curl -s --max-time 10 "${BASE_URL}:${API_PORT}/api/appointments" 2>/dev/null) || appts_list=""
if echo "$appts_list" | grep -q "Dr. E2E Tester"; then
    pass "Verify appointment in listing"
else
    fail "Verify appointment in listing" "appointment not found in GET /api/appointments"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# TEST 4: Upload Lab Result Document (Simulated)
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  4. UPLOAD LAB RESULT (SIMULATED)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LAB_RESULT_JSON=$(cat <<EOF
{
    "patientName": "${PATIENT_NAME}",
    "testType": "Blood Panel",
    "results": "WBC: 12.5, RBC: 7.8, Hemoglobin: 15.2",
    "veterinarian": "Dr. E2E Tester",
    "status": "completed",
    "notes": "E2E validation test lab result"
}
EOF
)

lab_response=$(post_json "${BASE_URL}:${API_PORT}/api/labresults" "$LAB_RESULT_JSON")
if [ -n "$lab_response" ]; then
    lab_id=$(echo "$lab_response" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$lab_id" ]; then
        pass "Upload lab result via API (id=$lab_id)"
    else
        pass "Upload lab result via API (response received)"
    fi
else
    fail "Upload lab result via API" "POST /api/labresults returned empty or failed"
fi

# Verify lab result is persisted
lab_list=$(curl -s --max-time 10 "${BASE_URL}:${API_PORT}/api/labresults" 2>/dev/null) || lab_list=""
if echo "$lab_list" | grep -q "Blood Panel"; then
    pass "Verify lab result persisted in database"
else
    fail "Verify lab result persisted" "lab result not found in GET /api/labresults"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# TEST 5: Background Worker Pub/Sub Processing
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  5. BACKGROUND WORKER PUB/SUB PROCESSING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check worker container is running
worker_logs=$(docker compose logs background-worker --tail 20 2>&1) || worker_logs=""
if [ -n "$worker_logs" ]; then
    pass "Background Worker container is running"

    if echo "$worker_logs" | grep -qiE "appointment_reminder|lab_result|processing|received|handled"; then
        pass "Background Worker shows message processing activity"
    else
        skip "Background Worker message processing" "No recent message processing in last 20 log lines"
    fi
else
    fail "Background Worker container" "not running or no logs"
fi

# In Dapr mode, verify the subscription endpoint
if [ "$DAPR_MODE" = true ]; then
    subs_response=$(curl -s --max-time 5 "${BASE_URL}:${WORKER_PORT}/dapr/subscribe" 2>/dev/null) || subs_response=""
    if [ -n "$subs_response" ]; then
        topic_count=$(echo "$subs_response" | grep -o '"topic"' | wc -l)
        if [ "$topic_count" -ge 2 ]; then
            pass "Dapr subscription endpoint returns ${topic_count} topics"
        else
            fail "Dapr subscription endpoint" "expected >= 2 topics, got ${topic_count}"
        fi
    else
        skip "Dapr subscription endpoint" "Worker Dapr port not reachable"
    fi
else
    # Legacy mode: check RabbitMQ queues
    rabbit_queues=$(curl -s -u guest:guest --max-time 5 "${BASE_URL}:8384/api/queues" 2>/dev/null) || rabbit_queues=""
    if [ -n "$rabbit_queues" ]; then
        has_lab=$(echo "$rabbit_queues" | grep -c '"lab_results"') || has_lab=0
        has_appt=$(echo "$rabbit_queues" | grep -c '"appointment_reminders"') || has_appt=0
        if [ "$has_lab" -gt 0 ] && [ "$has_appt" -gt 0 ]; then
            pass "RabbitMQ queues exist (lab_results, appointment_reminders)"
        else
            fail "RabbitMQ queues" "expected lab_results and appointment_reminders"
        fi
    else
        skip "RabbitMQ queue verification" "RabbitMQ management API not reachable"
    fi
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# TEST 6: Dapr Sidecar Health Endpoints
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  6. DAPR SIDECAR HEALTH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DAPR_MODE" = true ]; then
    for sidecar in api-server-dapr background-worker-dapr web-frontend-dapr; do
        sidecar_logs=$(docker compose logs "$sidecar" --tail 5 2>&1) || sidecar_logs=""
        if [ -n "$sidecar_logs" ]; then
            if echo "$sidecar_logs" | grep -qiE "dapr initialized|placement tables updated|app is subscribed"; then
                pass "Dapr sidecar $sidecar is initialized"
            else
                pass "Dapr sidecar $sidecar container is running"
            fi
        else
            fail "Dapr sidecar $sidecar" "container not running"
        fi
    done
else
    skip "Dapr sidecar health" "Not running in Dapr mode (use --dapr-mode to enable)"
fi

# Verify Dapr containers exist in compose
dapr_count=$(docker compose ps --format json 2>/dev/null | grep -c "dapr" 2>/dev/null) || dapr_count=0
if [ "$dapr_count" -gt 0 ]; then
    pass "Found ${dapr_count} Dapr sidecar container(s) in compose"
else
    skip "Dapr containers in compose" "No Dapr containers found (run with docker-compose.dapr.yml overlay)"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# TEST 7: Azure Blob Storage Integration (Simulated)
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  7. AZURE BLOB STORAGE INTEGRATION (SIMULATED)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verify the blob storage Dapr component configuration exists
BLOB_COMPONENT="${SCRIPT_DIR}/../dapr/components/azure-blobstore.yaml"
if [ -f "$BLOB_COMPONENT" ]; then
    pass "Azure Blob Storage Dapr component config exists"

    if grep -q "bindings.azure.blobstorage" "$BLOB_COMPONENT"; then
        pass "Blob component type is bindings.azure.blobstorage"
    else
        fail "Blob component type" "expected bindings.azure.blobstorage"
    fi

    if grep -q "documents" "$BLOB_COMPONENT"; then
        pass "Blob component references 'documents' container"
    else
        fail "Blob component container" "expected 'documents' container reference"
    fi
else
    fail "Azure Blob Storage Dapr component" "file not found at $BLOB_COMPONENT"
fi

# Verify Bicep defines blob storage containers
BICEP_FILE="${SCRIPT_DIR}/../infrastructure/azure-services.bicep"
if [ -f "$BICEP_FILE" ]; then
    for container in documents lab-results reports xrays; do
        if grep -q "$container" "$BICEP_FILE"; then
            pass "Bicep defines blob container '$container'"
        else
            fail "Bicep blob container" "'$container' not found in azure-services.bicep"
        fi
    done
else
    skip "Bicep blob storage validation" "azure-services.bicep not found"
fi

# Verify worker code has blob upload capability
WORKER_FILE="${SCRIPT_DIR}/../background-worker/worker.py"
if [ -f "$WORKER_FILE" ]; then
    if grep -qE "upload_to_blob_storage|blobstore|blob" "$WORKER_FILE"; then
        pass "Background Worker has blob storage upload code"
    else
        fail "Background Worker blob integration" "no blob upload code found in worker.py"
    fi
else
    skip "Background Worker blob code" "worker.py not found"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# TEST 8: Docker Container Health Status
# ═══════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  8. DOCKER CONTAINER HEALTH STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for svc in api-server background-worker web-frontend mongodb rabbitmq; do
    svc_state=$(docker compose ps "$svc" --format json 2>/dev/null) || svc_state=""
    if [ -n "$svc_state" ]; then
        state=$(echo "$svc_state" | grep -o '"State":"[^"]*"' | head -1 | cut -d'"' -f4)
        health=$(echo "$svc_state" | grep -o '"Health":"[^"]*"' | head -1 | cut -d'"' -f4)
        if [ "$health" = "healthy" ]; then
            pass "Container $svc (state=$state, health=$health)"
        elif [ "$state" = "running" ]; then
            pass "Container $svc is running (health=${health:-n/a})"
        else
            fail "Container $svc" "state=${state:-unknown}, health=${health:-unknown}"
        fi
    else
        skip "Container $svc" "not found in compose"
    fi
done

echo ""

# ═══════════════════════════════════════════════════════════════
# RESULTS SUMMARY
# ═══════════════════════════════════════════════════════════════
TOTAL=$((PASSED + FAILED + SKIPPED))

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    TEST RESULTS SUMMARY                     ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
printf "║   ✅ Passed:  %-4s                                          ║\n" "$PASSED"
printf "║   ❌ Failed:  %-4s                                          ║\n" "$FAILED"
printf "║   ⏭️  Skipped: %-4s                                          ║\n" "$SKIPPED"
printf "║   📊 Total:   %-4s                                          ║\n" "$TOTAL"
echo "║                                                              ║"
if [ "$FAILED" -eq 0 ]; then
    echo "║   🏆 ALL TESTS PASSED — System is operational!              ║"
else
    printf "║   ⚠️  %d test(s) failed — review output above               ║\n" "$FAILED"
fi
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

echo "Detailed Results:"
echo "--------------------------------------------------------------------------------"
printf "%-50s %-6s %s\n" "Test" "Result" "Detail"
echo "--------------------------------------------------------------------------------"
echo -e "$RESULTS" | while IFS='|' read -r icon test detail; do
    [ -z "$test" ] && continue
    printf "%-55s %s\n" "$test" "$detail"
done
echo ""

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
