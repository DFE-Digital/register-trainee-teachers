# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_disability, class: "TraineeDisability" do
    trainee
    disability factory: %i[disability mental_health_condition]
  end
end
