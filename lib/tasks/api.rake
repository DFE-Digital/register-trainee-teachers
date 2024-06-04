# frozen_string_literal: true

namespace :api do
  desc 'Generate new versioned API files'
  task :generate_new_version, [:old_version, :new_version] => :environment do |t, args|
    old_version = args[:old_version] || 'v0_1'
    new_version = args[:new_version] || 'v1_0'

    generator = ApiVersionGenerator.new(old_version: old_version, new_version: new_version)
    generator.generate_new_version
  end
end
