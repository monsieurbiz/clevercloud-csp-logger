#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_DIR="${ROOT_DIR}/app"
CONFIG_FILE="${APP_DIR}/conf/env.json"

if [[ ! -f "${APP_DIR}/csp-logger.js" ]]; then
  printf '[start] ERROR: app/csp-logger.js not found. Did clevercloud/pre_build.sh run?\n' >&2
  exit 1
fi

mkdir -p "${APP_DIR}/conf"

node > "${CONFIG_FILE}" <<'NODE'
const env = process.env;

const split = (value) => (value || '')
  .split(',')
  .map((item) => item.trim())
  .filter(Boolean);

const numberFromEnv = (value, fallback) => {
  const parsed = Number(value || fallback);

  return Number.isFinite(parsed) ? parsed : Number(fallback);
};

const config = {
  store: (env.STORE || 'sql').toLowerCase(),
  logger: {
    configuration: 'log4js.json',
  },
  health: {
    enabled: true,
  },
  port: numberFromEnv(env.PORT, 2600),
  domainWhitelist: split(env.DOMAIN_WHITELIST),
  sourceBlacklist: split(env.SOURCE_BLACKLIST),
  sql: {
    dbDialect: env.DB_DIALECT || 'mysql',
    dbHost: env.MYSQL_ADDON_HOST || env.DB_HOST || 'localhost',
    dbName: env.MYSQL_ADDON_DB || env.DB_NAME || 'csp',
    dbUsername: env.MYSQL_ADDON_USER || env.DB_USERNAME || '',
    dbPassword: env.MYSQL_ADDON_PASSWORD || env.DB_PASSWORD || '',
    dbPort: numberFromEnv(env.MYSQL_ADDON_PORT || env.DB_PORT, 3306),
  },
};

process.stdout.write(`${JSON.stringify(config, null, 2)}\n`);
NODE

exec node "${APP_DIR}/csp-logger.js" -c "${CONFIG_FILE}"
