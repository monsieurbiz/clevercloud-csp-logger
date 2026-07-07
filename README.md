# Clever Cloud CSP Logger wrapper

This repository is a thin Clever Cloud wrapper around upstream [`mozilla/csp-logger`](https://github.com/mozilla/csp-logger).

The Mozilla application source is not stored here. During Clever Cloud deployment the wrapper fetches it into the ignored `app/` directory, installs its production dependencies there, generates runtime configuration from environment variables, and starts it.

## Clever Cloud deployment flow

Configure these hooks in Clever Cloud:

```text
CC_PRE_BUILD_HOOK=./clevercloud/pre_build.sh
CC_POST_BUILD_HOOK=./clevercloud/post_build.sh
```

Clever Cloud can then launch the app with the root package script:

```text
npm start
```

which runs `./clevercloud/start.sh`.

## Upstream selection

Optional variables:

- `CSP_LOGGER_REPOSITORY` - Git repository to fetch. Defaults to `https://github.com/mozilla/csp-logger.git`.
- `CSP_LOGGER_REF` - branch, tag, or commit to deploy. Defaults to `master`.

## Runtime configuration

`clevercloud/start.sh` generates `app/conf/env.json` on each start. This file is intentionally ignored and must not be committed.

Supported variables:

- `STORE` - csp-logger store, defaults to `sql`.
- `PORT` - HTTP port, defaults to `2600`.
- `DOMAIN_WHITELIST` - required for functional logging; comma-separated host whitelist, converted to a JSON array. Use hosts only, without `https://`.
- `SOURCE_BLACKLIST` - comma-separated source blacklist, converted to a JSON array.
- `DB_DIALECT` - SQL dialect, defaults to `mysql`.
- `MYSQL_ADDON_HOST` or `DB_HOST` - database host, defaults to `localhost`.
- `MYSQL_ADDON_DB` or `DB_NAME` - database name, defaults to `csp`.
- `MYSQL_ADDON_USER` or `DB_USERNAME` - database username, defaults to empty.
- `MYSQL_ADDON_PASSWORD` or `DB_PASSWORD` - database password, defaults to empty.
- `MYSQL_ADDON_PORT` or `DB_PORT` - database port, defaults to `3306`.

Health checks are enabled in the generated configuration. Logger configuration remains set to `log4js.json` for upstream compatibility.

For a typical Clever Cloud MySQL deployment, set at least:

```text
STORE=sql
DOMAIN_WHITELIST=example.com,www.example.com
CC_PRE_BUILD_HOOK=clevercloud/pre_build.sh
CC_POST_BUILD_HOOK=clevercloud/post_build.sh
```

The Clever MySQL add-on variables are used automatically when present.
