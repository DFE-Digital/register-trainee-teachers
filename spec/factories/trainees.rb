# rubocop:disable Style/SymbolProc
FactoryBot.define do
  factory :abstract_trainee, class: Trainee do
    sequence :trainee_id do |n|
      n.to_s
    end
    first_names { Faker::Name.first_name }
    middle_names { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    gender { Trainee.genders.keys.sample }
    ethnicity { Faker::Nation.nationality }
    disability { %w[none something].sample }

    diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS.values.sample }
    ethnic_group { Diversities::ETHNIC_GROUP_ENUMS.values.sample }
    ethnic_background { nil }
    additional_ethnic_background { nil }
    disability_disclosure { Diversities::DISABILITY_DISCLOSURE_ENUMS.values.sample }

    address_line_one { Faker::Address.street_address }
    address_line_two { Faker::Address.street_name }
    town_city { Faker::Address.city }
    county { Faker::Address.state }
    postcode { Faker::Address.postcode }
    international_address { nil }
    locale_code { :uk }
    phone_number { [Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone].sample }
    email { "#{first_names}.#{last_name}@example.com" }

    start_date { Time.zone.now }
    full_time_part_time { %w[full_time part_time].sample }
    teaching_scholars { [false, true].sample }

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

    record_type { "assessment_only" }
  end
end

# rubocop:enable Style/SymbolProc
