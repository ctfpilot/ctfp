#!/usr/bin/env bash
# Select environment between test, dev or prod
# Usage: ./kubectl.sh [test|dev|prod]
CTFP_EXECUTE=true
if [ -z "$1" ]; then
  echo "Usage: $0 [test|dev|prod]"
  CTFP_EXECUTE=false
fi

if [ "$CTFP_EXECUTE" = true ]; then
    CTFP_ENVIRONMENT=$1
    echo "Setting up kubectl for environment: $CTFP_ENVIRONMENT"

    # Check if the kube-config directory exists, if not create it
    if [ ! -d "./kube-config" ]; then
        mkdir -p ./kube-config
    fi

    # Check if the kube-config file exists, if not then fail
    if [ -f "./kube-config/kube-config.$CTFP_ENVIRONMENT.yml" ]; then
        export KUBECONFIG=${KUBECONFIG:-~/.kube/config}:$(pwd)/kube-config/kube-config.$CTFP_ENVIRONMENT.yml
        kubectl config use-context k3s
        echo "KUBECONFIG set to k3s"
    else
        echo "Kube-config file not found!"
    fi
fi
