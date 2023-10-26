#!/usr/bin/env bash
# This script pulls down the latest charts using tk and then
# packages them into a tar.gz file to be vendored in the `charts` directory.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"

if ! command -v tk >/dev/null; then
  echo "Error: 'tk' is not installed. Please see the README for installation instructions." >&2
  exit 1
fi

if ! command -v helm >/dev/null; then
  echo "Error: 'helm' is not installed. Please see the README for installation instructions." >&2
  exit 1
fi

# run vendor where chartfile.yaml is located
(cd "$DIR/charts" && tk tool charts vendor --prune)

mv "$DIR/charts/charts"/* "$DIR/charts"
rm -rf "$DIR/charts/charts"

charts_dir="$DIR/charts"
for chart in "$charts_dir"/*; do
  if [[ ! -d "$chart" ]]; then
    continue
  fi

  if [[ "$chart" =~ datadog ]]; then
    # Remove the kube-state-metrics dependency
    rm -rf "$chart/charts/kube-state-metrics"

    # Remove it from the requirements.yaml
    yq -y '.dependencies | map(select(.name != "kube-state-metrics")) | {"dependencies": .}' "$chart/requirements.yaml" >"$chart/requirements.yaml.tmp"
    mv "$chart/requirements.yaml.tmp" "$chart/requirements.yaml"
  fi
  echo $chart
  echo $chart
  echo $chart
  echo $chart
  helm package "$chart" --destination "$charts_dir"
done

# Cleanup the unpacked charts
(cd "$charts_dir" && find . -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;)
