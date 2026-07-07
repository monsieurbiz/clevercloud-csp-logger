# Utilisation du CSP Logger

Ce document décrit l'exploitation de l'application une fois déployée sur Clever Cloud. Pour l'installation, voir [`README.md`](README.md).

## Routes exposées

- `GET /healthz` : health check.
- `POST /csp` : réception des rapports CSP.
- Pas de dashboard intégré.

`Cannot GET /csp` dans un navigateur est normal : `/csp` accepte uniquement les requêtes `POST`.

## Configurer un site surveillé

Sur le site à surveiller, ajouter une CSP en mode Report-Only qui envoie les violations vers l'application Clever Cloud :

```http
Content-Security-Policy-Report-Only: default-src 'self'; report-uri https://csp-logger.example.com/csp
```

Remplacer `https://csp-logger.example.com` par le domaine public de l'application CSP Logger.

Rappel : `DOMAIN_WHITELIST` doit contenir l'hôte du site surveillé uniquement, sans protocole ni chemin, par exemple :

```text
DOMAIN_WHITELIST=example.com,www.example.com
```

## Consulter les rapports

### Logs Clever Cloud

Les logs affichent le démarrage de l'application et peuvent afficher `Violation stored.` lorsqu'un rapport est accepté et enregistré.

### MySQL/MariaDB

Les rapports sont stockés dans la table `cspViolations`. Utiliser la console de l'add-on Clever Cloud ou un client MySQL avec les variables de l'add-on. Ne pas copier les identifiants dans le dépôt ni dans des logs publics.

Exemples SQL :

```sql
SHOW TABLES;
SELECT * FROM cspViolations ORDER BY createdAt DESC LIMIT 20;
SELECT blockedURI, documentURI, createdAt FROM cspViolations ORDER BY createdAt DESC LIMIT 20;
SELECT blockedURI, COUNT(*) AS total FROM cspViolations GROUP BY blockedURI ORDER BY total DESC LIMIT 20;
```

## Variables upstream utiles

Si besoin de figer ou remplacer le code upstream récupéré pendant le build :

- `CSP_LOGGER_REPOSITORY` : dépôt Git à récupérer, défaut `https://github.com/mozilla/csp-logger.git`.
- `CSP_LOGGER_REF` : branche, tag ou commit à déployer, défaut `master`.

Après modification, redéployer l'application.

## Dépannage

- `Cannot GET /csp` : normal, tester avec un vrai rapport CSP en `POST`.
- `app/csp-logger.js not found` : le hook `CC_PRE_BUILD_HOOK=clevercloud/pre_build.sh` n'a pas tourné ou a échoué.
- `app/package.json not found` pendant le build : vérifier que `CC_PRE_BUILD_HOOK=clevercloud/pre_build.sh` et `CC_POST_BUILD_HOOK=clevercloud/post_build.sh` sont configurés dans cet ordre.
- `POST /csp` retourne `200` mais rien en base : vérifier `STORE=sql`, `DOMAIN_WHITELIST`, les variables `MYSQL_ADDON_*`, puis redémarrer/redéployer après changement.
- Aucun rapport reçu : vérifier que la CSP du site utilise bien `report-uri https://<domaine-csp-logger>/csp` et que le navigateur déclenche une violation.
- Ref upstream introuvable : définir `CSP_LOGGER_REF` sur une branche, un tag ou un commit accessible.
