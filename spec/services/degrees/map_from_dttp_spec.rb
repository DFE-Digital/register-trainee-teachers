# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe MapFromDttp do
    let(:degree_subject) { DegreeSubjects::ANIMATION }
    let(:api_degree_qualification) do
      create(
        :api_degree_qualification,
        _dfe_degreesubjectid_value: Dttp::CodeSets::DegreeSubjects::MAPPING[degree_subject][:entity_id],
      )
    end

    let(:dttp_degree_qualification) { create(:dttp_degree_qualification, response: api_degree_qualification) }
    let(:graduation_year) { Date.parse(api_degree_qualification["dfe_degreeenddate"]).year }

    let!(:dttp_trainee) { create(:dttp_trainee, :with_placement_assignment, degree_qualifications: [dttp_degree_qualification]) }

    let(:common_attributes) do
      {
        subject: degree_subject,
        graduation_year: graduation_year,
      }
    end

    subject do
      described_class.call(
        dttp_degree: dttp_degree_qualification,
        dttp_trainee: dttp_trainee,
      )
    end

    it { is_expected.to be_a(Hash) }
    it { is_expected.to include(common_attributes) }

    context "with a JACS subject" do
      let(:degree_subject) { Dttp::CodeSets::JacsSubjects::MAPPING[degree_subject_entity_id] }
      let(:degree_subject_entity_id) { "85350ca9-e9c1-e611-80be-00155d010316" }

      let(:api_degree_qualification) do
        create(
          :api_degree_qualification,
          _dfe_degreesubjectid_value: degree_subject_entity_id,
        )
      end

      it { is_expected.to include(common_attributes) }
    end

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
          locale_code: Degree.locale_codes[:uk],
          uk_degree: degree_type,
          institution: institution,
          grade: grade,
        }
      end

      it { is_expected.to include(uk_degree_attributes) }

      context "with an inactive institution" do
        let(:institution) { Dttp::CodeSets::Institutions::INACTIVE_MAPPING[institution_entity_id] }
        let(:institution_entity_id) { "47f3791d-7042-e811-80ff-3863bb3640b8" }
        let(:api_degree_qualification) do
          create(
            :api_degree_qualification,
            _dfe_awardinginstitutionid_value: institution_entity_id,
            _dfe_degreetypeid_value: Dttp::CodeSets::DegreeTypes::MAPPING[degree_type][:entity_id],
            _dfe_classofdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
          )
        end

        it { is_expected.to include(uk_degree_attributes) }
      end

      context "with an inactive degree type" do
        let(:degree_type) { "BA/Education" }
        let(:api_degree_qualification) do
          create(
            :api_degree_qualification,
            _dfe_awardinginstitutionid_value: Dttp::CodeSets::Institutions::MAPPING[institution][:entity_id],
            _dfe_degreetypeid_value: "cf695652-c197-e711-80d8-005056ac45bb",
            _dfe_classofdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
          )
        end

        it { is_expected.to include(uk_degree_attributes) }
      end

      context "with a country that is part of the UK" do
        let(:country) { "Wales" }
        let(:api_degree_qualification) do
          create(
            :api_degree_qualification,
            _dfe_degreecountryid_value: Dttp::CodeSets::Countries::INACTIVE_MAPPING[country][:entity_id],
            _dfe_awardinginstitutionid_value: Dttp::CodeSets::Institutions::MAPPING[institution][:entity_id],
            _dfe_degreetypeid_value: Dttp::CodeSets::DegreeTypes::MAPPING[degree_type][:entity_id],
            _dfe_classofdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
          )
        end

        it { is_expected.to include(uk_degree_attributes) }
      end

      context "when there is no end date" do
        let(:api_degree_qualification) do
          create(
            :api_degree_qualification,
            _dfe_degreesubjectid_value: Dttp::CodeSets::DegreeSubjects::MAPPING[degree_subject][:entity_id],
            dfe_degreeenddate: nil,
            dfe_bursaryflag: bursary_flag,
          )
        end

        context "and the degree is bursary-related" do
          let(:bursary_flag) { 1 }

          it "picks the graduation date from the placement assignment" do
            expect(subject[:graduation_year]).not_to be_nil
            expect(subject[:graduation_year]).to eq(dttp_trainee.latest_placement_assignment.response["dfe_undergraddegreedateobtained"])
          end
        end

        context "and the degree is not bursary-related" do
          let(:bursary_flag) { 2 }

          it "ignores the graduation date from the placement assignment" do
            expect(subject[:graduation_year]).to be_nil
          end
        end
      end
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
          locale_code: Degree.locale_codes[:non_uk],
          non_uk_degree: api_degree_qualification["dfe_name"],
          country: country,
        }
      end

      it { is_expected.to include(non_uk_degree_attributes) }

      context "with an country not included in our dropdown" do
        let(:country) { "Guadeloupe" }
        let(:api_degree_qualification) do
          create(
            :api_degree_qualification,
            _dfe_degreecountryid_value: Dttp::CodeSets::Countries::INACTIVE_MAPPING[country][:entity_id],
          )
        end

        it { is_expected.to include(non_uk_degree_attributes) }
      end
    end
  end
end
