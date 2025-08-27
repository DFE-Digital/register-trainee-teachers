# Developing in GitHub Codespaces

## Creating a Codespace

To create a new Codespace for a branch, navigate to your branch in Github, select 'Code' and create a new codespace. This will create a virtual machine specific to the branch, running Postgres, Redis etc.

Note the setup process takes a few minutes, as it needs to install all the dependencies and generate a load of seed data.

## Making your Codespace visible to other team members

- Go to the Ports tab
- The website will be running on port 5001
- The context menu for the port will give you the option to adjust 'port visibility'. "Private to Organization" will mean anyone in the DfE GitHub organisation can access it, "Public" will mean anyone with the link can access it.

## Running tests

- Open a new terminal (`+` button)
- Run `bundle exec rspec spec/path-to-your-test-file.rb` to run a specific test file, or `bundle exec rspec spec` to run all tests.

## Modifying data in a Rails console

- Open a new terminal (`+` button)
- Run `bundle exec rails console`
- Now you can do things like `Trainee.first.update(first_names: 'Falafel')`

## Fetching latest changes to the branch

If there have been changes to the branch since you created the codespace, you can fetch them by:

- Open a new terminal (`+` button)
- Run `git pull`
