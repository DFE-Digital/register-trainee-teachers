# frozen_string_literal: true

FactoryBot.define do
  factory :hesa_trainee_detail, class: "Hesa::TraineeDetail" do
    trainee

    previous_last_name { Faker::Name.last_name }
    itt_aim { Hesa::CodeSets::IttAims::MAPPING.keys.sample }
    course_study_mode { "01" }
    course_year { Time.zone.today.year }
    course_age_range { DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.keys.sample }
    pg_apprenticeship_start_date { Time.zone.today }
    funding_method { Hesa::CodeSets::BursaryLevels::MAPPING.keys.sample }
    ni_number { "QQ 12 34 56 C" }

    additional_training_initiative { "026" }
    itt_qualification_aim { Hesa::CodeSets::IttQualificationAims::MAPPING.keys.sample }
    fund_code { Hesa::CodeSets::FundCodes::MAPPING.keys.sample }
  end
end
