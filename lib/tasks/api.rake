# frozen_string_literal: true

namespace :api do
  desc "Generate new versioned API files, e.g. rake api:generate_new_version[v2026.1,v2027.0]"
  task :generate_new_version, %i[old_version new_version] => :environment do |_t, args|
    old_version = args[:old_version]
    new_version = args[:new_version]

    ApiVersionGenerator.call(old_version:, new_version:)
  end

  desc "Generate new versioned spec files, e.g. rake api:generate_new_spec_version[v2026.1,v2027.0]"
  task :generate_new_spec_version, %i[old_version new_version] => :environment do |_t, args|
    old_version = args[:old_version]
    new_version = args[:new_version]

    SpecVersionGenerator.call(old_version:, new_version:)
  end

  desc "Rename an API version"
  task :rename_version, %i[old_version new_version] => :environment do |_t, args|
    old_version = args[:old_version]
    new_version = args[:new_version]

    ApiVersionUpdater.call(old_version:, new_version:)
  end
end
