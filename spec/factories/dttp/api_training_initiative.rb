# frozen_string_literal: true

FactoryBot.define do
  factory :api_training_initiative, class: Hash do
    dfe_initiativeid { SecureRandom.uuid }
    dfe_name do
      [
        "Transition to Teach",
        "Now Teach",
        "Employer engagement co-funded students",
      ].sample
    end
    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
