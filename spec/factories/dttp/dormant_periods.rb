# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_dormant_period, class: "Dttp::DormantPeriod" do
    dttp_id { SecureRandom.uuid }
    placement_assignment_dttp_id { SecureRandom.uuid }
    response {
      create(
        :api_dormant_period,
        dfe_dormantperiodid: dttp_id,
        _dfe_trainingrecordid_value: placement_assignment_dttp_id,
      )
    }
  end
end
