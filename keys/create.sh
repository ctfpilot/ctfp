#!/usr/bin/env bash

# Usage: ./create.sh [test|dev|prod]
CTFP_EXECUTE=true
if [ -z "$1" ]; then
  echo "Usage: $0 [test|dev|prod]"
  CTFP_EXECUTE=false
fi

if [ "$CTFP_EXECUTE" = true ]; then
  CTFP_ENVIRONMENT=$1
  echo "Creating SSH keys for environment: $CTFP_ENVIRONMENT"

  # Get location of this file
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

  ssh-keygen -t ed25519 -f "$DIR/k8s-$CTFP_ENVIRONMENT" -q -N ""

  # base64 encode the keys (into single base64 string)
  base64 "$DIR/k8s-$CTFP_ENVIRONMENT" -w0 > "$DIR/k8s-$CTFP_ENVIRONMENT.b64"
  base64 "$DIR/k8s-$CTFP_ENVIRONMENT.pub" -w0 > "$DIR/k8s-$CTFP_ENVIRONMENT.pub.b64"
fi
