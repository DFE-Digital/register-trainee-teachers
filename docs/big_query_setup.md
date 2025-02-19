Setting up BigQuery
===================

We use BigQuery to store analytics data about requests and entities.

To prepare a BigQuery data set to allow this:

* Create a service account
    * IAM > Service Accounts in the Google console
    * Create service account, we have one service account per app per env. Naming -> app-bigquery-env e.g register-bigquery-qa
    * Don’t worry about granting anything, just create
* Create a dataset - In the BigQuery console (https://console.cloud.google.com/bigquery)
    * Create data set on the root
    * Data set Id, for example `register_events_<environment>`
    * Data location europe-west2 (London)
    * Don’t enable expiry
    * Customer managed key
* Create a table ‘events’
    * Export the schema from an existing table.
        * Install the gcloud CLI if you do not have it (https://cloud.google.com/sdk/docs/install)
        * `gcloud auth login`
        * Select `rugged-abacus-218110` as the default project
        * Dump the schema `bq show --schema register_events_test.events` (dataset.table_name) of the table to copy
    * Copy the schema (the JSON array that is output from ^)
    * Create a new table from the schema (back in the BigQuery console)
        * Create from ‘Empty table’
        * Project - rugged-abacus-218110
        * Data set id - whatever was chosen up there ^, for example `register_events_qa`
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
* Setup the service account for workload identity federation.
	* See the DfE Analytics [README](https://github.com/DFE-Digital/dfe-analytics) on how to setup a service account for workload identity federation
	* Open your shiny new service account in ‘Workload Identity Federation‘ by clicking on:
	   IAM -> Workload Identity Federation
	* Navigate to the ‘CONNECTED SERVICE ACCOUNTS‘ for your pool and provider ie
	   ‘azure-cip-identity-pool‘ and ‘azure-cip-oidc-provider‘
	* Download the ‘Client library config‘ JSON for your service account
	* We add this JSON as a single line string to the env so get that with
        * `cat <filepath> | jq -c | jq -R` if you have `jq`
        * `JSON.parse(File.read(<filepath>)).to_json` in a ruby console. Parsing and to_json-ing is needed to strip the newlines
		* Put that where it needs to go. Register has a `GOOGLE_CLOUD_CREDENTIALS` env var set in the secrets.

The data set should be ready to receive events from a client authenticated with the credentials associated with the service account.
