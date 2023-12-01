# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_placement_row, class: "BulkUpdate::PlacementRow" do
    state { 1 }
    bulk_update_placement { nil }
    trn { "MyString" }
    urn { "MyString" }
    school { nil }
  end
end
