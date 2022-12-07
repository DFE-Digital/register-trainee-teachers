# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    user { create(:user, :system_admin) }
    name { "test.txt" }

    after(:build) do |upload|
      upload.file.attach(
        io: Rails.root.join("spec/fixtures/files/test.txt").open,
        filename: "test.txt",
        content_type: "text/text",
      )
    end
  end
end
