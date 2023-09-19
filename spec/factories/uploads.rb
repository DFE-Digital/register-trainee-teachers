# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    user factory: %i[user system_admin]
    name { "test.csv" }

    after(:build) do |upload|
      upload.file.attach(
        io: Rails.root.join("spec/fixtures/files/test.csv").open,
        filename: "test.csv",
        content_type: "text/csv",
      )
    end
  end
end
