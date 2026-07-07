#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_DIR="${ROOT_DIR}/app"

if [[ ! -f "${APP_DIR}/package.json" ]]; then
  printf '[post_build] ERROR: app/package.json not found. Did clevercloud/pre_build.sh run?\n' >&2
  exit 1
fi

cd "${APP_DIR}"

if [[ -f package-lock.json ]]; then
  npm ci --omit=dev
else
  npm install --omit=dev
fi
