# frozen_string_literal: true

FactoryBot.define do
  factory :api_bursary_detail, class: Hash do
    dfe_bursarydetailid { SecureRandom.uuid }
    dfe_name do
      [
        "School direct salaried",
        "Postgraduate Bursary",
        "Top - 1st Equivalent",
        "Middle - 2:1 Equivalent",
        "Bottom - 2:2 Equivalent",
        "Undergraduate bursary",
      ].sample
    end
    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
