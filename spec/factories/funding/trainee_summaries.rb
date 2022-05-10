# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_summary, class: "Funding::TraineeSummary" do
    academic_year { "2021" }

    trait :for_provider do
      payable { |p| p.association(:provider) }
    end

    trait :for_school do
      payable { |p| p.association(:school) }
    end
  end
end
