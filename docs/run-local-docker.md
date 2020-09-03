## Running the app using Docker

The purpose of this document to explain the steps involved in running the application using Docker.


### Setting the required environment variables
[direnv](https://direnv.net) is a shell extension which can be used to load environment variables under the current directory context. Please refer to instructions on the site to install and configure direnv.

Create an `.envrc` in the root of the repository with the below contents:
```
dotenv .env.development
```
You can specify variables as required in a `KEY=VALUE` format in the `.env.development` file and they will be loaded as environment variables.

### Building and running the docker image

#### Makefile

We have a Makefile with frequently used commands.

`make build` &nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;This will build the target docker image as specified in the docker-compose file.

`make dbsetup`&nbsp;:&nbsp;This will build the target docker image if not already present and set up the database in the local mount.

`make serve`&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: This will start the required services (postgres, redis) and also boot the application.

The application will now be available on http://localhost:3001
