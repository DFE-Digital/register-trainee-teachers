FactoryBot.define do
  factory :provider, class: Provider do
    sequence :name do |n|
      "Provider #{n}"
    end
  end
end
