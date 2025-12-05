# frozen_string_literal: true

require "rails_helper"

# rubocop:disable  Rails/RedundantActiveRecordAllMethod
RSpec.describe Hesa::ReferenceData::V20260 do
  include FileHelper

  describe "::all" do
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
      }.to_h do |attribute, mapping|
        transformed_mapping = if attribute.in? %i[subject]
                                mapping.sort
                              else
                                mapping.transform_values { |label| label[0].upcase + label[1..] }.sort
                              end
        translated_mapping  = transformed_mapping.map { |code, label| [code, I18n.t("#{attribute}.#{code}", default: label)] }

        [attribute, translated_mapping.to_h]
      end
    end

    it "returns the mapped hesa code sets" do
      code_sets.each do |attribute, mapping|
        expect(described_class.all[attribute].to_a).to eq(mapping.to_a)
      end
    end
  end

  describe "::find" do
    let(:attribute) { "funding_method" }

    it "returns an attribute's hesa code sets" do
      expect(described_class.find(attribute).values).to eq(
        Hesa::CodeSets::BursaryLevels::VALUES,
      )
    end
  end

  describe "as_csv" do
    it "converts data to csv" do
      expect(
        CSV.parse(described_class.find(:course_age_range).as_csv),
      ).to eq(
        CSV.parse(file_content("reference_data/v2025_0/course_age_range.csv")),
      )
    end
  end
end
# rubocop:enable  Rails/RedundantActiveRecordAllMethod
