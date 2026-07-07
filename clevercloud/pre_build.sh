#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

REPOSITORY="${CSP_LOGGER_REPOSITORY:-https://github.com/mozilla/csp-logger.git}"
REF="${CSP_LOGGER_REF:-master}"
APP_DIR="${ROOT_DIR}/app"
TMP_ROOT="${ROOT_DIR}/.tmp"
TMP_DIR="${TMP_ROOT}/csp-logger-fetch"

log() {
  printf '[pre_build] %s\n' "$*"
}

fetch_ref() {
  local ref="$1"

  if git fetch --depth 1 origin "$ref"; then
    return 0
  fi

  if git fetch --depth 1 origin "refs/heads/${ref}"; then
    return 0
  fi

  if git fetch --depth 1 origin "refs/tags/${ref}"; then
    return 0
  fi

  return 1
}

log "preparing upstream source"
log "repository: ${REPOSITORY}"
log "ref: ${REF}"

rm -rf "${APP_DIR}" "${TMP_DIR}"
mkdir -p "${APP_DIR}" "${TMP_ROOT}" "${TMP_DIR}"

git -C "${TMP_DIR}" init --quiet
git -C "${TMP_DIR}" remote add origin "${REPOSITORY}"

if ! (cd "${TMP_DIR}" && fetch_ref "${REF}"); then
  printf '[pre_build] ERROR: unable to fetch ref "%s" from %s\n' "${REF}" "${REPOSITORY}" >&2
  printf '[pre_build] Set CSP_LOGGER_REF to an existing branch, tag, or fetchable commit.\n' >&2
  exit 1
fi

git -C "${TMP_DIR}" checkout --quiet FETCH_HEAD

(cd "${TMP_DIR}" && tar --exclude .git -cf - .) | (cd "${APP_DIR}" && tar -xf -)

log "upstream source copied to app/"
