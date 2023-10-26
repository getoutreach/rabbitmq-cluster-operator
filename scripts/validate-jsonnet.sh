#!/usr/bin/env bash
# Ensures that the jsonnet files are valid
set -euo pipefail

if ! command -v kubecfg >/dev/null; then
  echo "Error: 'kubecfg' is not installed. Please see the README for installation instructions." >&2
  exit 1
fi

if ! command -v kubeconform >/dev/null; then
  echo "Error: 'kubeconform' is not installed. Please see the README for installation instructions." >&2
  exit 1
fi

if ! command -v dyff >/dev/null; then
  echo "Error: 'dyff' is not installed. Please see the README for installation instructions." >&2
  exit 1
fi

tempFile=$(mktemp -t manifests.XXXXXX)
trap 'rm -f $tempFile' EXIT

echo "[info] Rendering Jsonnet"
if ! kubecfg \
  --jurl http://k8s-clusters.outreach.cloud/ \
  --jurl https://raw.githubusercontent.com/getoutreach/jsonnet-libs/master \
  show ./*.jsonnet -oyaml >"$tempFile"; then
  echo "[error] Failed to validate jsonnet files"
  exit 1
fi

if [[ ! -e "tests/basic/snapshot.yaml" ]]; then
  echo "[info] No snapshot found, creating one"
  cp "$tempFile" "tests/basic/snapshot.yaml"
fi

# Validate that the generated yaml is the same as the snapshot
if ! dyff between --set-exit-code "tests/basic/snapshot.yaml" "$tempFile"; then
  echo -e "\033[0;31m[error] Generated yaml does not match snapshot\033[0m"
  exit 1
fi

echo "[info] Validating generated yaml"
if ! kubeconform -summary \
  -schema-location default \
  -ignore-missing-schemas \
  -strict \
  -kubernetes-version 1.22.17 \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
  <"$tempFile"; then
  echo -e "\033[0;31m[error] Failed to validate generated yaml\033[0m"
  exit 1
fi
