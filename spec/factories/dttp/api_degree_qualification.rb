# frozen_string_literal: true

FactoryBot.define do
  factory :api_degree_qualification, class: Hash do
    dfe_degreequalificationid { SecureRandom.uuid }
    _dfe_contactid_value { SecureRandom.uuid }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
