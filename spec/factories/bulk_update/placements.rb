# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_placement, class: "BulkUpdate::Placement" do
    provider

    after(:build) do |upload|
      upload.file.attach(
        io: Rails.root.join("spec/fixtures/files/bulk_update/placements/complete.csv").open,
        filename: "test.csv",
      )
    end
  end
end
