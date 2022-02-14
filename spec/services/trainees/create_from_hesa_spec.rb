# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromHesa do
    let(:nationality_name) { ApplyApi::CodeSets::Nationalities::MAPPING[student_attributes[:nationality]] }
    let(:hesa_disability_codes) { Hesa::CodeSets::Disabilities::MAPPING.invert }
    let(:hesa_ethnicity_codes) { Hesa::CodeSets::Ethnicities::MAPPING.invert }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING[student_attributes[:training_route]] }
    let(:hesa_api_stub) { ApiStubs::HesaApi.new(hesa_stub_attributes) }
    let(:student_node) { hesa_api_stub.student_node }
    let(:student_attributes) { hesa_api_stub.student_attributes }
    let(:create_custom_state) { "implemented where necessary" }
    let(:hesa_stub_attributes) { {} }

    subject(:trainee) { Trainee.first }

    before do
      create(:nationality, name: nationality_name)
      create(:provider, ukprn: student_attributes[:ukprn])
      create_custom_state
      described_class.call(student_node: student_node)
    end

    it "updates the trainee from HESA XML document" do
      expect(trainee.hesa_id).to eq(student_attributes[:hesa_id])
      expect(trainee.first_names).to eq(student_attributes[:first_names])
      expect(trainee.last_name).to eq(student_attributes[:last_name])
      expect(trainee.address_line_one).to eq(student_attributes[:address_line_one])
      expect(trainee.address_line_two).to eq(student_attributes[:address_line_two])
      expect(trainee.email).to eq(student_attributes[:email])
      expect(trainee.date_of_birth).to eq(Date.parse(student_attributes[:date_of_birth]))
      expect(trainee.gender).to eq("female")
      expect(trainee.trainee_id).to eq(student_attributes[:trainee_id])
      expect(trainee.nationalities.pluck(:name)).to include(nationality_name)
      expect(trainee.trn).to eq(student_attributes[:trn])
    end

    context "trainee doesn't exist" do
      describe "#created_from_hesa" do
        subject { trainee.created_from_hesa }

        it { is_expected.to eq(true) }
      end
    end

    context "trainee already exists and didn't come from HESA" do
      let(:create_custom_state) { create(:trainee, hesa_id: student_attributes[:hesa_id]) }

      describe "#created_from_hesa" do
        subject { trainee.created_from_hesa }

        it { is_expected.to eq(false) }
      end

      context "when ethnicity is missing" do
        let(:hesa_stub_attributes) { { ethnic_background: nil } }

        it "sets the ethnic_group and background to 'Not provided'" do
          expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
          expect(trainee.ethnic_background).to eq(Diversities::NOT_PROVIDED)
        end
      end

      context "when ethnicity is explicitly 'not provided'" do
        let(:hesa_stub_attributes) do
          { ethnic_background: hesa_disability_codes[Diversities::NOT_PROVIDED] }
        end

        it "sets the ethnic_group and background to 'Not provided'" do
          expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
          expect(trainee.ethnic_background).to eq(Diversities::NOT_PROVIDED)
        end
      end

      context "when neither ethnicity nor disabilities are disclosed" do
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_disability_codes[Diversities::INFORMATION_REFUSED],
            disability: nil,
          }
        end

        it "sets the diversity disclosure to 'diversity_not_disclosed'" do
          expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed])
        end
      end

      context "when just disability is disclosed" do
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_ethnicity_codes[Diversities::INFORMATION_REFUSED],
            disability: hesa_disability_codes[Diversities::LEARNING_DIFFICULTY],
          }
        end

        it "sets the diversity disclosure to 'diversity_disclosed'" do
          expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
        end
      end

      context "when disability is 'MULTIPLE_DISABILITIES'" do
        let(:trainee_disability) { trainee.trainee_disabilities.last }
        let(:create_custom_state) { create(:disability, name: Diversities::OTHER) }
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_ethnicity_codes[Diversities::INFORMATION_REFUSED],
            disability: hesa_disability_codes[Diversities::MULTIPLE_DISABILITIES],
          }
        end

        it "saves the disability as 'other' and sets the additional_diversity text" do
          expect(trainee_disability.additional_disability).to eq(Trainees::CreateFromHesa::MULTIPLE_DISABILITIES_TEXT)
          expect(trainee_disability.disability.name).to eq(Diversities::OTHER)
        end
      end

      context "when just ethnicity is disclosed" do
        let(:hesa_stub_attributes) { { ethnic_background: hesa_ethnicity_codes[Diversities::AFRICAN] } }

        it "sets the diversity disclosure to 'diversity_disclosed'" do
          expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
        end
      end

      context "when ethnicity is information_refused" do
        let(:hesa_stub_attributes) { { ethnic_background: hesa_ethnicity_codes[Diversities::INFORMATION_REFUSED] } }

        it "sets the ethnic_group to 'Not provided'" do
          expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
        end
      end
    end
  end
end
