FactoryBot.define do
  factory :trainee_withdrawal, class: 'Trainee::Withdrawal' do
    association :trainee
    date { "2024-11-18" }
    trigger { :provider }
    another_reason { "Not enough coffee" }
    future_interest { :yes }
  end
end