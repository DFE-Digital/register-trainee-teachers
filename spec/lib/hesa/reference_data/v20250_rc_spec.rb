# frozen_string_literal: true

require "rails_helper"

# rubocop:disable  Rails/RedundantActiveRecordAllMethod
RSpec.describe Hesa::ReferenceData::V20250Rc do
  describe "::call" do
    let(:code_sets) do
      {
        funding_method: Hesa::CodeSets::BursaryLevels::VALUES,
        institution: DfEReference::DegreesQuery::INSTITUTIONS.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
        grade: DfEReference::DegreesQuery::GRADES.all.pluck(:hesa_code, :name).to_h.reject { |k, _v| k.nil? },
        uk_degree: DfEReference::DegreesQuery::TYPES.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
        non_uk_degree: DfEReference::DegreesQuery::TYPES.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
        disability1: Hesa::CodeSets::Disabilities::MAPPING,
        disability2: Hesa::CodeSets::Disabilities::MAPPING,
        disability3: Hesa::CodeSets::Disabilities::MAPPING,
        disability4: Hesa::CodeSets::Disabilities::MAPPING,
        disability5: Hesa::CodeSets::Disabilities::MAPPING,
        disability6: Hesa::CodeSets::Disabilities::MAPPING,
        disability7: Hesa::CodeSets::Disabilities::MAPPING,
        disability8: Hesa::CodeSets::Disabilities::MAPPING,
        disability9: Hesa::CodeSets::Disabilities::MAPPING,
        country: Hesa::CodeSets::Countries::MAPPING,
        training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.transform_values(&:humanize),
        subject: DfEReference::DegreesQuery::SUBJECTS.all.pluck(:hecos_code, :name).to_h.reject { |k, _v| k.nil? },
        ethnicity: Hesa::CodeSets::Ethnicities::MAPPING,
        fund_code: Hesa::CodeSets::FundCodes::MAPPING,
        training_initiative: Hesa::CodeSets::TrainingInitiatives::MAPPING.transform_values(&:humanize),
        itt_aim: Hesa::CodeSets::IttAims::MAPPING,
        course_age_range: DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.transform_values { |value| "Ages #{value.join('-')}" },
        study_mode: Hesa::CodeSets::StudyModes::MAPPING.transform_values { |value| Trainee.study_modes.invert[value].humanize },
        itt_qualification_aim: Hesa::CodeSets::IttQualificationAims::MAPPING,
        sex: Hesa::CodeSets::Sexes::MAPPING.transform_values { |value| Trainee.sexes.invert[value].humanize },
        course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING,
        course_subject_two: Hesa::CodeSets::CourseSubjects::MAPPING,
        course_subject_three: Hesa::CodeSets::CourseSubjects::MAPPING,
        nationality: RecruitsApi::CodeSets::Nationalities::MAPPING,
      }.transform_values { |mapping| mapping.sort.to_h }
    end

    it "returns the mapped hesa code sets" do
      code_sets.each do |attribute, mapping|
        expect(described_class.call[attribute].to_a).to eq(mapping.to_a)
      end
    end
  end
end
# rubocop:enable  Rails/RedundantActiveRecordAllMethod
