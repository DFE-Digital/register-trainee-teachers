# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_placement_assignment, class: "Dttp::PlacementAssignment" do
    dttp_id { SecureRandom.uuid }
    contact_dttp_id { SecureRandom.uuid }
    provider_dttp_id { SecureRandom.uuid }
    academic_year { SecureRandom.uuid }
    programme_start_date { Faker::Date.in_date_period(month: 9) }
    programme_end_date { Faker::Date.in_date_period(month: 8, year: Faker::Date.in_date_period.year + 1) }
    trainee_status { SecureRandom.uuid }
    response {
      create(
        :api_placement_assignment,
        dttp_id: dttp_id,
        contact_dttp_id: contact_dttp_id,
        provider_dttp_id: provider_dttp_id,
        _dfe_academicyearid_value: academic_year,
        dfe_programmestartdate: programme_start_date.strftime("%Y-%m-%d"),
        dfe_programmeenddate: programme_end_date.strftime("%Y-%m-%d"),
      )
    }
  end
end
