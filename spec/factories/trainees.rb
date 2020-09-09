# rubocop:disable Style/SymbolProc
FactoryBot.define do
  factory :abstract_trainee, class: Trainee do
    sequence :trainee_id do |n|
      n.to_s
    end
    first_names { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { %w[Female Male Other].sample }

    nationality { Faker::Nation.nationality }
    ethnicity { Faker::Nation.nationality }
    disability { %w[none something].sample }

    a_level_1_subject { "Maths" }
    a_level_1_grade { %w[A B C].sample }
    a_level_2_subject { "Geography" }
    a_level_2_grade { %w[A B C].sample }
    a_level_3_subject { "Physics" }
    a_level_3_grade { %w[A B C].sample }
    degree_subject { "Software Engineering" }
    degree_class { "2:1" }
    degree_institution { Faker::University.name }
    degree_type { "BSc" }
    ske { "SKE not required" }
    previous_qts { false }

    address_line_one { Faker::Address.street_address }
    address_line_two { Faker::Address.street_name }
    town_city { Faker::Address.city }
    county { Faker::Address.state }
    postcode { Faker::Address.postcode }
    phone { [Faker::PhoneNumber.phone_number, Faker::PhoneNumber.cell_phone].sample }
    email { "#{first_names}.#{last_name}@example.com" }
    start_date { Time.zone.now }
    full_time_part_time { %w[full_time part_time].sample }
    teaching_scholars { [false, true].sample }
    factory :trainee do
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    end

    factory :trainee_for_form do
      add_attribute("date_of_birth(3i)") { Faker::Date.birthday(min_age: 18, max_age: 65).day.to_s }
      add_attribute("date_of_birth(2i)") { Faker::Date.birthday(min_age: 18, max_age: 65).month.to_s }
      add_attribute("date_of_birth(1i)") { Faker::Date.birthday(min_age: 18, max_age: 65).year.to_s }
    end
  end
end
# rubocop:enable Style/SymbolProc
