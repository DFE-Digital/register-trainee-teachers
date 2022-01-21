# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_dormant_period, class: "Dttp::DormantPeriod" do
    transient do
      defer_date { Faker::Date.in_date_period }
      reinstate_date { Faker::Date.in_date_period }
    end
    dttp_id { SecureRandom.uuid }
    placement_assignment_dttp_id { SecureRandom.uuid }
    response {
      create(
        :api_dormant_period,
        dfe_dormantperiodid: dttp_id,
        _dfe_trainingrecordid_value: placement_assignment_dttp_id,
        dfe_dateleftcourse: defer_date,
        dfe_datereturnedtocourse: reinstate_date,
      )
    }
  end
end
