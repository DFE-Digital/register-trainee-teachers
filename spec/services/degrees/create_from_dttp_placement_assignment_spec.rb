# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromDttpPlacementAssignment do
    let(:provider) { create(:provider) }
    let(:api_placement_assignment) { create(:api_placement_assignment) }
    let(:placement_assignment) { create(:dttp_placement_assignment, provider_dttp_id: provider.dttp_id, response: api_placement_assignment) }
    let(:dttp_trainee) { create(:dttp_trainee, placement_assignments: [placement_assignment]) }
    let(:degree_subject) { DegreeSubjects::ECONOMICS }
    let(:institution) { Dttp::CodeSets::Institutions::GOLDSMITHS_COLLEGE }
    let(:grade) { Dttp::CodeSets::Grades::FIRST_CLASS_HONOURS }
    let(:degree_type) { Dttp::CodeSets::DegreeTypes::BACHELOR_OF_ARTS }
    let(:trainee) { create(:trainee, dttp_id: dttp_trainee.dttp_id) }
    let!(:dttp_degree_qualification) { create(:dttp_degree_qualification, dttp_trainee:) }

    subject(:create_from_placement_assignment) { described_class.call(trainee:) }

    it "does not create a degree" do
      expect {
        create_from_placement_assignment
      }.not_to change(trainee.degrees, :count)
    end

    context "when no degree_qualifications exist" do
      let!(:dttp_degree_qualification) { nil }
      let(:api_placement_assignment) do
        create(
          :api_placement_assignment,
          _dfe_awardinginstitutionid_value: Dttp::CodeSets::Institutions::MAPPING[institution][:entity_id],
          _dfe_subjectofugdegreeid_value: Dttp::CodeSets::DegreeSubjects::MAPPING[degree_subject][:entity_id],
          _dfe_firstdegreeorequivalentid_value: Dttp::CodeSets::DegreeTypes::MAPPING[degree_type][:entity_id],
          _dfe_classofugdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
        )
      end
      let(:common_degree_attributes) do
        {
          subject: degree_subject,
          institution: institution,
          grade: grade,
        }
      end

      context "when the trainee has a degree" do
        before do
          trainee.degrees << create(:degree)
        end

        it "does not create a degree from the placement_assignment" do
          expect {
            create_from_placement_assignment
          }.not_to change(trainee.degrees, :count)
        end
      end

      it "creates a degree from the placement_assignment" do
        expect {
          create_from_placement_assignment
        }.to change(trainee.degrees, :count).by(1)
      end

      it { is_expected.to have_attributes(common_degree_attributes) }

      context "with a JACS subject" do
        let(:degree_subject) { Dttp::CodeSets::JacsSubjects::MAPPING[degree_subject_entity_id] }
        let(:degree_subject_entity_id) { "85350ca9-e9c1-e611-80be-00155d010316" }

        let(:api_placement_assignment) do
          create(
            :api_placement_assignment,
            _dfe_awardinginstitutionid_value: Dttp::CodeSets::Institutions::MAPPING[institution][:entity_id],
            _dfe_subjectofugdegreeid_value: degree_subject_entity_id,
            _dfe_firstdegreeorequivalentid_value: Dttp::CodeSets::DegreeTypes::MAPPING[degree_type][:entity_id],
            _dfe_classofugdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
          )
        end

        it { is_expected.to have_attributes(common_degree_attributes) }
      end

      context "with an inactive institution" do
        let(:institution) { Dttp::CodeSets::Institutions::INACTIVE_MAPPING[institution_entity_id] }
        let(:institution_entity_id) { "47f3791d-7042-e811-80ff-3863bb3640b8" }
        let(:api_placement_assignment) do
          create(
            :api_placement_assignment,
            _dfe_awardinginstitutionid_value: institution_entity_id,
            _dfe_subjectofugdegreeid_value: Dttp::CodeSets::DegreeSubjects::MAPPING[degree_subject][:entity_id],
            _dfe_firstdegreeorequivalentid_value: Dttp::CodeSets::DegreeTypes::MAPPING[degree_type][:entity_id],
            _dfe_classofugdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
          )
        end

        it { is_expected.to have_attributes(common_degree_attributes) }
      end

      context "with an inactive degree type" do
        let(:degree_type) { "BA/Education" }
        let(:api_placement_assignment) do
          create(
            :api_placement_assignment,
            _dfe_awardinginstitutionid_value: Dttp::CodeSets::Institutions::MAPPING[institution][:entity_id],
            _dfe_subjectofugdegreeid_value: Dttp::CodeSets::DegreeSubjects::MAPPING[degree_subject][:entity_id],
            _dfe_firstdegreeorequivalentid_value: Dttp::CodeSets::DegreeTypes::INACTIVE_MAPPING[degree_type][:entity_id],
            _dfe_classofugdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
          )
        end

        it { is_expected.to have_attributes(common_degree_attributes) }
      end

      context "with an DegreeOrEquivalentQualification degree type" do
        let(:degree_type) { "UK degree (England)" }
        let(:api_placement_assignment) do
          create(
            :api_placement_assignment,
            _dfe_awardinginstitutionid_value: Dttp::CodeSets::Institutions::MAPPING[institution][:entity_id],
            _dfe_subjectofugdegreeid_value: Dttp::CodeSets::DegreeSubjects::MAPPING[degree_subject][:entity_id],
            _dfe_firstdegreeorequivalentid_value: Dttp::CodeSets::DegreeOrEquivalentQualifications::MAPPING[degree_type][:entity_id],
            _dfe_classofugdegreeid_value: Dttp::CodeSets::Grades::MAPPING[grade][:entity_id],
          )
        end

        it { is_expected.to have_attributes(common_degree_attributes) }
      end

      context "with uk degree attributes" do
        let(:uk_degree_attributes) do
          {
            locale_code: "uk",
            uk_degree: degree_type,
          }
        end

        it { is_expected.to have_attributes(uk_degree_attributes) }

        context "with a uk country value" do
          let(:country) { "United Kingdom" }
          let(:api_placement_assignment) do
            create(
              :api_placement_assignment,
              _dfe_firstdegreeorequivalentid_value: Dttp::CodeSets::DegreeTypes::MAPPING[degree_type][:entity_id],
              _dfe_overseastrainedteachercountryid_value: Dttp::CodeSets::Countries::MAPPING[country][:entity_id],
            )
          end

          it { is_expected.to have_attributes(uk_degree_attributes) }
        end
      end

      context "with non-uk degree attributes" do
        let(:country) { "France" }
        let(:api_placement_assignment) do
          create(
            :api_placement_assignment,
            _dfe_firstdegreeorequivalentid_value: Dttp::CodeSets::DegreeTypes::MAPPING[degree_type][:entity_id],
            _dfe_overseastrainedteachercountryid_value: Dttp::CodeSets::Countries::MAPPING[country][:entity_id],
          )
        end

        let(:non_uk_degree_attributes) do
          {
            locale_code: "non_uk",
            uk_degree: nil,
            non_uk_degree: degree_type,
          }
        end

        it { is_expected.to have_attributes(non_uk_degree_attributes) }
      end
    end
  end
end
