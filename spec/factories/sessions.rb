# frozen_string_literal: true

FactoryBot.define do
  factory :session, class: "ActiveRecord::SessionStore::Session" do
    session_id { SecureRandom.uuid }
    data { Faker::Lorem.paragraph }

    trait :recent_session do
      created_at { 1.day.ago }
      updated_at { 1.day.ago }
    end

    trait :old_session do
      created_at { Settings.session_store.expire_after_days.days.ago }
      updated_at { Settings.session_store.expire_after_days.days.ago }
    end
  end
end
