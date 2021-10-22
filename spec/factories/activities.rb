# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    user
    controller_name { "trainees" }
    action_name { "index" }
    metadata { { format: "csv" } }
  end
end
