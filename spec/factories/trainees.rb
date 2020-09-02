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
