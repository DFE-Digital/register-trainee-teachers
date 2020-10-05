FactoryBot.define do
  factory :nationality do
    sequence(:name) { |n| "nationality #{n}" }
  end
end
