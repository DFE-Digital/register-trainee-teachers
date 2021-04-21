# frozen_string_literal: true

FactoryBot.define do
  factory :validation_error do
    user
    form_object { "PersonalDetailsForm" }
    details { { "gender" => { "value" => nil, "messages" => ["You must select a gender", "is not included in the list"] }, "last_name" => { "value" => "", "messages" => ["You must enter a last name"] }, "first_names" => { "value" => "", "messages" => ["You must enter a first name"] }, "date_of_birth" => { "value" => { "table" => { "day" => "", "year" => "", "month" => "" } }, "messages" => ["You must enter a valid date"] }, "nationality_ids" => { "value" => [], "messages" => ["You must select at least one nationality"] } } }
  end
end
