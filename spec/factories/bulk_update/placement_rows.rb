# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_placement_row, class: "BulkUpdate::PlacementRow" do
    state { :pending }
    bulk_update_placement
    sequence(:csv_row_number)
    trn { Faker::Number.number(digits: 7) }
    urn { school.urn }
    school
  end
end
