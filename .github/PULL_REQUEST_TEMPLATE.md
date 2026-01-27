### Context

### Changes proposed in this pull request

### Guidance to review

### Important business

- [ ] Does this PR introduce any PII fields that need to be overwritten or deleted in db/scripts/sanitise.sql?
- [ ] Does this PR change the database schema? If so, have you updated the config/analytics.yml file and considered whether you need to send 'import_entity' events?
- [ ] Do we need to send any updates to TRS as part of the work in this PR?
- [ ] Does this PR need an ADR?

NB: Please notify the #twd_data_insights team and ask for a review if new fields are being added to analytics.yml
