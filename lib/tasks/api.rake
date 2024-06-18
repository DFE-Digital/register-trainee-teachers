# frozen_string_literal: true

namespace :api do
  desc "Generate new versioned API files"
  task :generate_new_version, %i[old_version new_version] => :environment do |_t, args|
    old_version = args[:old_version] || "v0.1"
    new_version = args[:new_version] || "v1.0"

    ApiVersionGenerator.call(old_version:, new_version:)
  end

  desc "Generate new versioned spec files"
  task :generate_new_spec_version, %i[old_version new_version] => :environment do |_t, args|
    old_version = args[:old_version] || "v0.1"
    new_version = args[:new_version] || "v1.0"

    SpecVersionGenerator.call(old_version:, new_version:)
  end
end
