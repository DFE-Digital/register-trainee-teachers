# frozen_string_literal: true

FactoryBot.define do
  factory :provider, class: "Provider" do
    sequence :name do |n|
      "Provider #{n}"
    end
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    ukprn { Faker::Number.unique.number(digits: 8) }

    after(:build) do |provider|
      counter = 0

      loop do
        raise StandardError, "Retry limit exceeded" if counter == 3

        number           = Faker::Number.number(digits: 3)
        accreditation_id = "#{provider.name.include?('University') ? 1 : 5}#{number}"

        if Provider.exists?(accreditation_id:)
          counter += 1
        else
          provider.accreditation_id ||= accreditation_id

          break
        end
      end
    end

    after(:create) do |provider|
      if provider.provider_users.empty?
        create(:provider_user, provider:)
      end
    end

    trait :unaccredited do
      accredited { false }
    end

    trait :teach_first do
      code { Provider::TEACH_FIRST_PROVIDER_CODE }
    end

    trait :ambition do
      code { Provider::AMBITION_PROVIDER_CODE }
    end

    trait :with_courses do
      transient do
        courses_count { 1 }
        course_code { Faker::Alphanumeric.unique.alphanumeric(number: 4, min_alpha: 1).upcase }
      end

      after(:create) do |provider, evaluator|
        create_list(:course, evaluator.courses_count, code: evaluator.course_code, accredited_body_code: provider.code)
      end
    end

    trait :with_dttp_id do
      dttp_id { SecureRandom.uuid }
    end

    trait :hei do
      accreditation_id { Faker::Number.within(range: 1000..1999)    }
    end

    trait :scitt do
      accreditation_id { Faker::Number.within(range: 5000..5999)    }
    end

    trait :performance_profile_sign_off do
      sign_offs { [build(:sign_off, :performance_profile)] }
    end

    trait :previous_performance_profile_sign_off do
      sign_offs { [build(:sign_off, :performance_profile, :previous_academic_cycle)] }
    end

    trait :census_sign_off do
      sign_offs { [build(:sign_off, :census)] }
    end
  end
end
