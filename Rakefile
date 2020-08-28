# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

if %w[development test].include?(Rails.env)
  task default: ["lint:ruby", "lint:javascript", "lint:scss", :spec]
end
