#!/usr/bin/env bash

# Get location of this file
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

ssh-keygen -t ed25519 -f $DIR/k8s -q -N ""

# base64 encode the keys (into single base64 string)
base64 $DIR/k8s | tr -d '\n' >$DIR/k8s.b64
base64 $DIR/k8s.pub | tr -d '\n' >$DIR/k8s.pub.b64
