# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

if %w[development test].include?(Rails.env)

  desc "Runs JS unit tests with yarn"
  task javascript_specs: :environment do
    system "yarn test"
  end

  task default: ["lint:erb", "lint:ruby", "lint:javascript", "lint:scss", :spec, :javascript_specs]
end
