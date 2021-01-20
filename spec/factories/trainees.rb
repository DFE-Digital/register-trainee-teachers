# frozen_string_literal: true

# rubocop:disable Style/SymbolProc
FactoryBot.define do
  factory :abstract_trainee, class: Trainee do
    sequence :trainee_id do |n|
      n.to_s
    end

    provider

    record_type { "assessment_only" }

    first_names { Faker::Name.first_name }
    middle_names { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    gender { Trainee.genders.keys.sample }
    slug { SecureRandom.base58(Sluggable::SLUG_LENGTH) }

    diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS.values.sample }
    ethnic_group { Diversities::ETHNIC_GROUP_ENUMS.values.sample }
    ethnic_background { nil }
    additional_ethnic_background { nil }
    disability_disclosure { Diversities::DISABILITY_DISCLOSURE_ENUMS.values.sample }

    address_line_one { Faker::Address.street_address }
    address_line_two { Faker::Address.street_name }
    town_city { Faker::Address.city }
    postcode { Faker::Address.postcode }
    international_address { nil }
    locale_code { :uk }
    email { "#{first_names}.#{last_name}@example.com" }

    factory :trainee do
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    end

    factory :trainee_for_form do
      transient do
        form_dob { Faker::Date.birthday(min_age: 18, max_age: 65) }
      end
      add_attribute("date_of_birth(3i)") { form_dob.day.to_s }
      add_attribute("date_of_birth(2i)") { form_dob.month.to_s }
      add_attribute("date_of_birth(1i)") { form_dob.year.to_s }
    end

    trait :with_programme_details do
      subject { Dttp::CodeSets::ProgrammeSubjects::MAPPING.keys.sample }
      age_range { Dttp::CodeSets::AgeRanges::MAPPING.keys.sample }
      programme_start_date { Faker::Date.between(from: 10.years.ago, to: 2.days.ago) }
      programme_end_date { Faker::Date.between(from: programme_start_date + 1.day, to: Time.zone.today) }
    end

    trait :diversity_disclosed do
      diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] }
      ethnic_background { Dttp::CodeSets::Ethnicities::MAPPING.keys.sample }
    end

    trait :diversity_not_disclosed do
      diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] }
    end

    trait :with_placement_assignment do
      placement_assignment_dttp_id { SecureRandom.uuid }
    end

    trait :with_outcome_date do
      outcome_date { Faker::Date.in_date_period }
    end

    trait :draft do
      state { "draft" }
    end

    trait :submitted_for_trn do
      state { "submitted_for_trn" }
      submitted_for_trn_at { Time.zone.now }
      dttp_id { SecureRandom.uuid }
    end

    trait :trn_received do
      state { "trn_received" }
      dttp_id { SecureRandom.uuid }
    end

    trait :recommended_for_qts do
      state { "recommended_for_qts" }
    end

    trait :withdrawn do
      state { "withdrawn" }
    end

    trait :deferred do
      state { "deferred" }
    end

    trait :qts_awarded do
      state { "qts_awarded" }
    end

    trait :withdrawn_on_another_day do
      withdraw_date { Faker::Date.in_date_period }
    end

    trait :withdrawn_for_specific_reason do
      withdraw_date { Time.zone.today }
      withdraw_reason { WithdrawalReasons::SPECIFIC.sample }
    end

    trait :withdrawn_for_another_reason do
      withdraw_date { Faker::Date.in_date_period }
      withdraw_reason { WithdrawalReasons::FOR_ANOTHER_REASON }
      additional_withdraw_reason { Faker::Lorem.paragraph }
    end
  end
end

# rubocop:enable Style/SymbolProc
