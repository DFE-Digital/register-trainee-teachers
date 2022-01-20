# frozen_string_literal: true

FactoryBot.define do
  factory :api_dormant_period, class: Hash do
    dfe_dormantperiodid { SecureRandom.uuid }
    _dfe_trainingrecordid_value { SecureRandom.uuid }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
