#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# deploy-azure.sh
# Builds Docker images, pushes to ACR, and deploys PawsCare to Azure
# Container Apps using Bicep.
###############################################################################

# --- Configuration (update these placeholders) ---
SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-<your-subscription-id>}"
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-<your-resource-group>}"
LOCATION="${AZURE_LOCATION:-eastus}"
ENVIRONMENT="${DEPLOY_ENVIRONMENT:-dev}"
BASE_NAME="${BASE_NAME:-pawscare}"
IMAGE_TAG="${IMAGE_TAG:-$(git rev-parse --short HEAD 2>/dev/null || echo latest)}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Helper functions ---
info()  { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }
ok()    { echo -e "\033[1;32m[OK]\033[0m    $*"; }

# --- Pre-flight checks ---
for cmd in az docker; do
  if ! command -v "$cmd" &>/dev/null; then
    error "'$cmd' is required but not found. Please install it first."
    exit 1
  fi
done

info "Setting Azure subscription to $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"

# --- Step 1: Create resource group if it doesn't exist ---
info "Ensuring resource group '$RESOURCE_GROUP' exists in '$LOCATION'..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
ok "Resource group ready."

# --- Step 2: Deploy infrastructure (ACR + Container Apps Environment) ---
info "Deploying base infrastructure (ACR, Log Analytics, Container Apps Environment)..."
INFRA_OUTPUT=$(az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$REPO_ROOT/infrastructure/main.bicep" \
  --parameters environment="$ENVIRONMENT" baseName="$BASE_NAME" \
  --query "properties.outputs" \
  --output json)

ACR_LOGIN_SERVER=$(echo "$INFRA_OUTPUT" | jq -r '.acrLoginServer.value')
ACR_NAME=$(echo "$INFRA_OUTPUT" | jq -r '.acrName.value')
ok "Infrastructure deployed. ACR: $ACR_LOGIN_SERVER"

# --- Step 3: Log in to ACR ---
info "Logging in to Azure Container Registry '$ACR_NAME'..."
az acr login --name "$ACR_NAME"
ok "Logged in to ACR."

# --- Step 4: Build and push Docker images ---
SERVICES=("web-frontend" "api-server" "background-worker")

for SERVICE in "${SERVICES[@]}"; do
  IMAGE_NAME="$ACR_LOGIN_SERVER/pawscare/$SERVICE:$IMAGE_TAG"
  info "Building image for $SERVICE..."
  docker build -t "$IMAGE_NAME" "$REPO_ROOT/$SERVICE"
  info "Pushing $IMAGE_NAME..."
  docker push "$IMAGE_NAME"
  ok "$SERVICE image pushed."
done

# --- Step 5: Deploy Container Apps ---
info "Deploying Container Apps with Dapr sidecars..."
DEPLOY_OUTPUT=$(az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$REPO_ROOT/infrastructure/deploy.bicep" \
  --parameters \
    environment="$ENVIRONMENT" \
    baseName="$BASE_NAME" \
    imageTag="$IMAGE_TAG" \
  --query "properties.outputs" \
  --output json)

ok "Deployment complete!"

# --- Step 6: Output results ---
echo ""
echo "============================================="
echo "  PawsCare Deployment Summary"
echo "============================================="
echo ""
echo "  ACR Login Server:    $ACR_LOGIN_SERVER"
echo "  Image Tag:           $IMAGE_TAG"
echo "  Environment:         $ENVIRONMENT"
echo ""
echo "  Web Frontend URL:    $(echo "$DEPLOY_OUTPUT" | jq -r '.webFrontendUrl.value')"
echo "  API Server FQDN:     $(echo "$DEPLOY_OUTPUT" | jq -r '.apiServerFqdn.value')"
echo "  Worker:              $(echo "$DEPLOY_OUTPUT" | jq -r '.backgroundWorkerName.value')"
echo ""
echo "============================================="
