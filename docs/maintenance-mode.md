# Maintenance mode

The repo includes a simple service unavailable page page that can be pushed to a cf app.  Traffic can be rerouted to it instead of the main application. This is handy in case of a critical bug being discovered where we need to take the service offline, or in case of maintenance where we want to avoid users interacting with the service.

When enabled, all requests will receive the [service unavailable page](/service_unavailable_page/web/public/internal/index.html).

## Instructions

* Update maintenance page with content as necessary
* Update first update message with current time and date
* Deploy with below instructions
* Add further updates to the page through the day

## Deploy Maintenance mode

Login to PaaS: `cf login --sso` or `cf login -o dfe -u my.name@digital.education.gov.uk`

Run the make command: `make prod enable-maintenance CONFIRM_PRODUCTION=y`

To bring the application back up: `make prod disable-maintenance CONFIRM_PRODUCTION=y`
