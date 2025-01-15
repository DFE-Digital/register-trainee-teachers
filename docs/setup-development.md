# Installation

Clone the repo:

    git clone git@github.com:DFE-Digital/register-trainee-teachers.git

## Setup the application libraries and dependencies

Run setup:

```bash
./bin/setup
```

Run yarn:

```bash
yarn install
```

Add a file to config/settings called development.local.yml containing the following:

```yml
    features:
      use_ssl: false
```

## Start the server

To start all the processes you'll need to first create a local `Procfile.dev` file with the following:

```
web: bin/rails server -p 3000
js: yarn build --watch
css: yarn build:css --watch
worker: bundle exec sidekiq -t 25 -C config/sidekiq.yml
```

there is a `Procfile.dev.sample` you can rename and modify to do this.

Then run the following command:

```bash
./bin/dev
```

To run the processes seperately, you can do the following:

1. Run `bundle exec rails server` to launch the app on http://localhost:5000
2. Run `yarn build --watch` for js
3. Run `yarn build:css --watch` for css

## Using Docker

Run this in a shell and leave it running after cloning the repo:

```
docker compose up --build --detach
```

You can then follow the log output with

```
docker compose logs --follow
```

The first time you run the app, you need to set up the databases. With the above command running separately, do:

```
docker compose exec web /bin/sh -c "bundle exec rails db:setup"
```

And make sure to seed the application with whichever data you need.

Then open http://localhost:3001 to see the app.

## Run The Server in SSL Mode

By default the server does not run in SSL mode. If you want to run the local
server in SSL mode, you can do so by setting the environment variable
`SETTINGS__USE_SSL`, for example, use this command to run the server:

```bash
SETTINGS__USE_SSL=1 rails s
```

### Trust the TLS certificate

Depending on your browser you may need to add the automatically generated SSL certificate to your OS keychain to make the browser trust the local site.

On macOS:

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain config/localhost/https/localhost.crt
```

When running the https local dev environment if you are on Mac and using Chrome you may need to get past an invalid certificate screen. <https://stackoverflow.com/questions/58802767/no-proceed-anyway-option-on-neterr-cert-invalid-in-chrome-on-macos>

## Seeding Data

### Example Data

If you want to seed the database with example data, follow the steps below:

```shell
bin/rails example_data:generate
```

#### Using a Dev persona (optional)

This will allow you to create a dev persona with your own email address - useful for when testing mailers/notify.

create the file `config/initializers/developer_persona.rb` and add your own credentials in the format:

```ruby
DEVELOPER_PERSONA = { first_name: "first", last_name: "last", email: "first.last@education.gov.uk", system_admin: true }.freeze
```

### Sanitised Data

If you want to seed the database with a sanitised production dump, follow the steps below:

- Download the sanitised production dump from the Azure Storage Account.
- In the Azure portal, go to 'Storage Accounts' -> 's189p01rttdbbkppdsa' -> 'Containers' -> 'database-backup'
- Download the latest sanitised backup.
- Unzip the file and you should see a file called `backup_sanitised.sql`.

Then run the following command to populate the database:

```bash
psql register_trainee_teacher_data_development < ~/Downloads/backup_sanitised.sql
```

## Schools data
[Get Information about Schools](https://get-information-schools.service.gov.uk) holds the most complete information for schools.
[Teacher Training Courses API](https://api.publish-teacher-training-courses.service.gov.uk) holds the most complete information for lead schools.

In order to create and update the schools and the lead schools follow the below steps
1. [Download Get Information about Schools data](#download-get-information-about-schools-data)
2. [Generate data/schools_gias.csv from GIAS data](#generate-dataschools_giascsv-from-gias-data)
3. [Import schools from csv data/schools_gias.cs](#import-schools-from-csv-dataschools_giascsv)

### Download Get Information about Schools data
1. Go to [Get Information about Schools Download page](https://get-information-schools.service.gov.uk/Downloads)
2. From `Open academies and free schools data` select `Academies and free school fields CSV`
3. From `Open state-funded schools data` select `State-funded school fields CSV`
4. Click on `Download selected files`
5. Extract content to `./data` directory

### Generate data/schools_gias.csv from GIAS data
To generate the data/schools_gias.csv from GIAS data, use the following rake task:

```bash

# gias_csv_1_path: path to the GIAS file
# gias_csv_2_path: path to the GIAS file
# output_path: optional, path to the output file, default to `data/schools_gias.csv`
bundle exec rake schools_data:generate_csv_from_gias\[gias_csv_1_path,gias_csv_2_path,output_path\]

# as an example
  bundle exec rake schools_data:generate_csv_from_gias\[./data/edubaseallacademiesandfree20250115.csv,./data/edubaseallstatefunded20250115.csv\]

```

### Import schools from csv data/schools_gias.csv
To import schools from csv data/schools_gias.csv, use the following rake task:

```bash
bundle exec rake schools_data:import_gias
```


## Running Apply application import against example data

Add the following to your `development.local.yml`:

```yml
features:
  import_applications_from_apply: true

recruits_api:
  base_url: "https://sandbox.apply-for-teacher-training.service.gov.uk/register-api"
  auth_token: <request token from Apply team>
```

Running the following script:

```ruby
RecruitsApi::ImportApplication.class_eval do
  def provider
    Provider.all.sample
  end
end
ApplyApplicationSyncRequest.delete_all
RecruitsApi::ImportApplicationsJob.perform_now
```
