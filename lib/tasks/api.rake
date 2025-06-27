# frozen_string_literal: true

namespace :api do
  desc "Generate new versioned API files"
  task :generate_new_version, %i[old_version new_version] => :environment do |_t, args|
    old_version = args[:old_version] || "v2025.0-rc"
    new_version = args[:new_version] || "v2025.1-rc"

    ApiVersionGenerator.call(old_version:, new_version:)
  end

  desc "Generate new versioned spec files"
  task :generate_new_spec_version, %i[old_version new_version] => :environment do |_t, args|
    old_version = args[:old_version] || "v2025.0-rc"
    new_version = args[:new_version] || "v2025.1-rc"

    SpecVersionGenerator.call(old_version:, new_version:)
  end

  desc "Rename an API version"
  task :rename_version, %i[old_version new_version] => :environment do |_t, args|
    old_version = args[:old_version]
    new_version = args[:new_version]

    ApiVersionUpdater.call(old_version:, new_version:)
  end
end
