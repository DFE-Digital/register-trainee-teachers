# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    user factory: %i[user system_admin]
    name { "test.csv" }
    transient do
      fixture_name { "test.csv" }
    end

    after(:build) do |upload, evaluator|
      upload.file.attach(
        io: Rails.root.join("spec/fixtures/files/#{evaluator.fixture_name}").open,
        filename: "test.csv",
        content_type: "text/csv",
      )
    end
  end
end
