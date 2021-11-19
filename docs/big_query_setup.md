Setting up BigQuery
===================

We use BigQuery to store analytics data about requests and entities.

To prepare a BigQuery data set to allow this:

* Create a service account
    * IAM > Service Accounts in the Google console
    * Create service account, we have one service account per app per env. Naming -> app-bigquery-env e.g register-bigquery-qa
    * Don’t worry about granting anything, just create
* Get a key, this will be needed in the ENV
    * Open your shiny new service account by clicking on the ‘email’ in the list
    * Keys -> Add Key - JSON
    * We add this JSON as a single line string to the env so get that with
        * `cat <filepath> | jq -c | jq -R` if you have `jq`
        * `JSON.parse(File.read(<filepath>)).to_json` in a ruby console. Parsing and to_json-ing is needed to strip the newlines
    * Put that where it needs to go. Register has a `SETTINGS__GOOGLE__BIG_QUERY__API_JSON_KEY` env var set in the secrets.
* Create a dataset - In the BigQuery console (https://console.cloud.google.com/bigquery)
    * Create data set on the root
    * Data set Id e.g. register_events_<environment>
    * Data location europe-west2 (London)
    * Don’t enable expiry
    * Google managed key
* Create a table ‘events’
    * Export the schema from an existing table.
        * Install the gcloud CLI if you don't have it (https://cloud.google.com/sdk/docs/install)
        * `gcloud auth login`
        * Select `rugged-abacus-218110` as the default project
        * Dump the schema `bq show --schema register_events_test.events` (dataset.table_name) of the table to copy
    * Copy the schema (the JSON array that is output from ^)
    * Create a new table from the schema (back in the BigQuery console)
        * Create from ‘Empty table’
        * Project - rugged-abacus-218110
        * Data set id - whatever was chosen up there ^ e.g. register_events_qa
        * Table name - events
        * Table type - Native table
        * Schema - edit as text and then paste the JSON array schema in
        * Create table
* Take a break, this is going well
* Add the service account to the dataset
    * Open the dataset (in the BigQuery console)
    * Go to ‘Sharing’ -> ‘Permissions’
    * Add principal
        * New principals - service account email address
        * Select a role - Custom -> Custom BigQuery Data Appender
        * Save

The data set should be ready to receive events from a client authenticated with the credentials assocated with the service account. 
