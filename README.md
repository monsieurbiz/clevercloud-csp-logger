# Clever Cloud CSP Logger wrapper

Wrapper Clever Cloud très léger autour de [`mozilla/csp-logger`](https://github.com/mozilla/csp-logger). Le code upstream n'est pas versionné ici : il est récupéré dans `app/` pendant le build, puis configuré au démarrage avec les variables d'environnement Clever Cloud.

Pour l'utilisation après déploiement, voir [`docs.md`](docs.md).

## Démarrage rapide Clever Cloud

1. Créer une application Clever Cloud de type **Node.js & Bun**.
2. Ajouter un add-on **MySQL/MariaDB** et le lier à l'application.
   - Les variables `MYSQL_ADDON_*` sont fournies automatiquement par l'add-on lié.
   - Pas besoin de filesystem persistant : `app/` est reconstruit à chaque build.
3. Configurer les variables d'environnement de l'application :

   ```text
   CC_PRE_BUILD_HOOK=clevercloud/pre_build.sh
   CC_POST_BUILD_HOOK=clevercloud/post_build.sh
   STORE=sql
   DOMAIN_WHITELIST=example.com,www.example.com
   # Optionnel : branche, tag ou commit upstream à déployer
   CSP_LOGGER_REF=master
   # Optionnel : sources CSP à ignorer, séparées par des virgules
   SOURCE_BLACKLIST=
   ```

   `DOMAIN_WHITELIST` contient uniquement des hôtes, sans `https://` ni chemin.

4. Déployer vers la branche Clever `master` :

   ```sh
   git push clever main:master
   ```

## Scripts du wrapper

- `clevercloud/pre_build.sh` : récupère `mozilla/csp-logger` (ou `CSP_LOGGER_REPOSITORY`) dans `app/`, sur `CSP_LOGGER_REF` ou `master` par défaut.
- `clevercloud/post_build.sh` : installe les dépendances de production upstream dans `app/` (`npm ci --omit=dev` si possible, sinon `npm install --omit=dev`).
- `clevercloud/start.sh` : génère `app/conf/env.json` depuis les variables d'environnement, puis lance `node app/csp-logger.js`.
- `npm start` : lance `clevercloud/start.sh`.

## Variables runtime utiles

- `STORE` : backend de stockage, recommandé `sql`.
- `PORT` : port HTTP, fourni par Clever Cloud ou `2600` par défaut.
- `DOMAIN_WHITELIST` : liste d'hôtes autorisés, séparés par des virgules.
- `SOURCE_BLACKLIST` : liste optionnelle de sources à ignorer, séparées par des virgules.
- `DB_DIALECT` : dialecte SQL, `mysql` par défaut.
- `MYSQL_ADDON_HOST`, `MYSQL_ADDON_DB`, `MYSQL_ADDON_USER`, `MYSQL_ADDON_PASSWORD`, `MYSQL_ADDON_PORT` : fournis par l'add-on MySQL/MariaDB lié.
- Alternatives manuelles si besoin : `DB_HOST`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`, `DB_PORT`.

## Sélection de l'upstream

- `CSP_LOGGER_REPOSITORY` : dépôt Git à récupérer, défaut `https://github.com/mozilla/csp-logger.git`.
- `CSP_LOGGER_REF` : branche, tag ou commit à déployer, défaut `master`.
