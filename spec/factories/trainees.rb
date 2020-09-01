# rubocop:disable Style/SymbolProc
FactoryBot.define do
  factory :trainee do
  end

  factory :trainee_for_form, class: Trainee do
    sequence :trainee_id do |n|
      n.to_s
    end
    first_names { "Steve" }
    last_name { "Smith" }
    gender { "Male" }
    add_attribute("date_of_birth(3i)") { "29" }
    add_attribute("date_of_birth(2i)") { "4" }
    add_attribute("date_of_birth(1i)") { "1999" }
    nationality { "british" }
    ethnicity { "british" }
    disability { "none" }
  end
end
# rubocop:enable Style/SymbolProc
