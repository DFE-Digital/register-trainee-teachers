# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe MapFromDttp do
    let(:degree_subject) { Dttp::CodeSets::DegreeSubjects::ANIMATION }
    let(:api_degree_qualification) do
      create(
        :api_degree_qualification,
        _dfe_degreesubjectid_value: Dttp::CodeSets::DegreeSubjects::MAPPING[degree_subject][:entity_id],
      )
    end

    let(:dttp_degree_qualification) { create(:dttp_degree_qualification, response: api_degree_qualification) }
    let(:graduation_year) { Date.parse(api_degree_qualification["dfe_degreeenddate"]).year }

    let(:common_attributes) do
      {
        subject: degree_subject,
        graduation_year: graduation_year,
      }
    end

    subject { described_class.call(dttp_degree: dttp_degree_qualification) }

    it { is_expected.to be_a(Hash) }
    it { is_expected.to include(common_attributes) }

    context "with a uk degree" do
      let(:institution) { Dttp::CodeSets::Institutions::GOLDSMITHS_COLLEGE }
      let(:degree_type) { Dttp::CodeSets::DegreeTypes::BACHELOR_OF_ARTS }
      let(:grade) { Dttp::CodeSets::Grades::FIRST_CLASS_HONOURS }

      let(:api_degree_qualification) do
        create(
          :api_degree_qualification,
          _dfe_awardinginstitutionid_value: Dttp::CodeSets::Institutions::MAPPING[institution][:entity_id],
          _dfe_degreetypeid_value: Dttp::CodeSets::DegreeTypes::MAPPING[degree_type][:entity_id],
          _dfe_classofdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
        )
      end

      let(:uk_degree_attributes) do
        {
          locale_code: Trainee.locale_codes[:uk],
          uk_degree: degree_type,
          institution: institution,
          grade: grade,
        }
      end

      it { is_expected.to include(uk_degree_attributes) }
    end

    context "with a non-uk degree" do
      let(:country) { "France" }
      let(:api_degree_qualification) do
        create(
          :api_degree_qualification,
          _dfe_degreecountryid_value: Dttp::CodeSets::Countries::MAPPING[country][:entity_id],
        )
      end

      let(:non_uk_degree_attributes) do
        {
          locale_code: Trainee.locale_codes[:non_uk],
          non_uk_degree: api_degree_qualification["dfe_name"],
          country: country,
        }
      end

      it { is_expected.to include(non_uk_degree_attributes) }
    end
  end
end
