### Context

### Changes proposed in this pull request

### Guidance to review

### Important business

* Does this PR introduce any PII fields that need to be overwritten or deleted in db/scripts/sanitise.sql?
* Does this PR change the database schema? If so, have you updated the config/analytics.yml file and considered whether you need to send 'import_entity' events?
