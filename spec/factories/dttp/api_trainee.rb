# frozen_string_literal: true

FactoryBot.define do
  factory :api_trainee, class: Hash do
    contactid { SecureRandom.uuid }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
