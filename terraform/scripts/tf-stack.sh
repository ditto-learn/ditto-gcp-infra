#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <platform|database|runtime> <test|prod> <plan|apply|destroy>" >&2
  exit 1
fi

COMPONENT="$1"
ENV="$2"
ACTION="$3"

if [[ "$COMPONENT" != "platform" && "$COMPONENT" != "database" && "$COMPONENT" != "runtime" ]]; then
  echo "COMPONENT must be platform, database, or runtime" >&2
  exit 1
fi

if [[ "$ENV" != "test" && "$ENV" != "prod" ]]; then
  echo "ENV must be test or prod" >&2
  exit 1
fi

if [[ "$ACTION" != "plan" && "$ACTION" != "apply" && "$ACTION" != "destroy" ]]; then
  echo "ACTION must be plan, apply, or destroy" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPONENT_DIR="$ROOT_DIR/$COMPONENT"
TFVARS_FILE="$COMPONENT_DIR/variables/$ENV.tfvars"
STATE_BUCKET_VAR="TF_STATE_BUCKET_${ENV^^}"
STATE_BUCKET="${!STATE_BUCKET_VAR:-}"

if [[ -z "$STATE_BUCKET" ]]; then
  echo "Set $STATE_BUCKET_VAR to your GCS backend bucket." >&2
  exit 1
fi

STATE_PREFIX="components/$COMPONENT/$ENV"
PLAN_FILE=".tfplan.$COMPONENT.$ENV"

cd "$COMPONENT_DIR"

terraform init -reconfigure \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="prefix=$STATE_PREFIX"

if [[ "$ACTION" == "plan" ]]; then
  terraform plan -var-file="$TFVARS_FILE" -out="$PLAN_FILE"
elif [[ "$ACTION" == "apply" ]]; then
  terraform plan -var-file="$TFVARS_FILE" -out="$PLAN_FILE" -input=false
  terraform apply "$PLAN_FILE"
else
  terraform destroy -var-file="$TFVARS_FILE" -auto-approve
fi
