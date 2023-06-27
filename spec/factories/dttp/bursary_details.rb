# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_bursary_detail, class: "Dttp::BursaryDetail" do
    dttp_id { SecureRandom.uuid }
    response {
      association(
        :api_bursary_detail,
        dfe_bursarydetailid: dttp_id,
      )
    }
  end
end
