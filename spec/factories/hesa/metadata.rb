# frozen_string_literal: true

FactoryBot.define do
  factory :hesa_metadatum, class: "Hesa::Metadatum" do
    study_length do
      {
        weeks: [53, 68],
        months: [9, 10, 11, 12, 14, 16, 20, 36],
        years: (1..4).to_a,
      }[study_length_unit].sample
    end
    study_length_unit { %i[weeks months years].sample }
    itt_aim { Hesa::CodeSets::IttAims::MAPPING.values.sample }
    itt_qualification_aim { Hesa::CodeSets::IttQualificationAims::MAPPING.values.sample }
    fundability { Hesa::CodeSets::FundCodes::MAPPING.values.sample }
    year_of_course { (0..5).to_a.sample }
  end
end
