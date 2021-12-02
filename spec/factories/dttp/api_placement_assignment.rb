# frozen_string_literal: true

FactoryBot.define do
  factory :api_placement_assignment, class: Hash do
    dfe_placementassignmentid { SecureRandom.uuid }
    _dfe_contactid_value { SecureRandom.uuid }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
