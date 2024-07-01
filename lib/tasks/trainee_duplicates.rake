# frozen_string_literal: true

namespace :trainee_duplicates do
  desc "Remove trainee duplicates"
  task :remove_duplicates, [:file_path] => :environment do |_t, args|
    raise "You must provide a file path" unless args[:file_path]
  end
end
