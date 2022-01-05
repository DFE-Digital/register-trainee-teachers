# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromDttp do
    let(:dttp_trainee) { create(:dttp_trainee) }
    let(:api_degree_qualification) { create(:api_degree_qualification) }
    let!(:dttp_degree_qualification) { create(:dttp_degree_qualification, dttp_trainee: dttp_trainee, response: api_degree_qualification) }
    let(:trainee) { create(:trainee, dttp_trainee: dttp_trainee) }

    subject(:create_from_dttp) { described_class.call(trainee: trainee) }

    shared_examples "invalid" do
      it "does not save the degree" do
        expect { create_from_dttp }.not_to change(trainee.degrees, :count)
      end
    end

    it "creates a degree against the provided trainee" do
      expect {
        create_from_dttp
      }.to change(trainee.degrees, :count).by(1)
    end

    it "changes the state to imported" do
      expect {
        create_from_dttp
      }.to change {
        dttp_degree_qualification.reload.state
      }.from("importable").to("imported")
    end

    context "when the trainee does not have a corresponding dttp_trainee" do
      let(:trainee) { create(:trainee) }

      it "raises an error" do
        expect {
          create_from_dttp
        }.to raise_error(described_class::DttpTraineeNotFound)
      end
    end

    context "when details are missing (not unmapped)" do
      let(:api_degree_qualification) do
        create(
          :api_degree_qualification,
          _dfe_degreesubjectid_value: nil,
          _dfe_degreetypeid_value: nil,
          _dfe_awardinginstitutionid_value: nil,
        )
      end
      let!(:dttp_degree_qualification) { create(:dttp_degree_qualification, dttp_trainee: dttp_trainee, response: api_degree_qualification) }

      it "creates a degree with missing data" do
        expect {
          create_from_dttp
        }.to change(trainee.degrees, :count).by(1)
      end
    end

    context "when the degree has an unmapped subject" do
      let(:unmapped_subject) { "Creative accounting" }
      let(:api_degree_qualification) { create(:api_degree_qualification, _dfe_degreesubjectid_value: unmapped_subject) }

      include_examples "invalid"

      it "changes the state to non_importable_missing_subject" do
        expect {
          create_from_dttp
        }.to change {
          dttp_degree_qualification.reload.state
        }.from("importable").to("non_importable_missing_subject")
      end
    end

    context "when the degree has an unmapped country" do
      let(:unmapped_country) { "Isle of Woman" }
      let(:api_degree_qualification) { create(:api_degree_qualification, _dfe_degreecountryid_value: unmapped_country) }

      include_examples "invalid"

      it "changes the state to non_importable_missing_country" do
        expect {
          create_from_dttp
        }.to change {
          dttp_degree_qualification.reload.state
        }.from("importable").to("non_importable_missing_country")
      end
    end

    context "when the degree has an unmapped degree type" do
      let(:unmapped_type) { "Triple first class plus" }
      let(:api_degree_qualification) { create(:api_degree_qualification, _dfe_degreetypeid_value: unmapped_type) }

      include_examples "invalid"

      it "changes the state to non_importable_missing_type" do
        expect {
          create_from_dttp
        }.to change {
          dttp_degree_qualification.reload.state
        }.from("importable").to("non_importable_missing_type")
      end
    end

    context "when the degree has an unmapped institution" do
      let(:unmapped_institution) { "University of Foxford" }
      let(:api_degree_qualification) { create(:api_degree_qualification, _dfe_awardinginstitutionid_value: unmapped_institution) }

      include_examples "invalid"

      it "changes the state to non_importable_missing_institution" do
        expect {
          create_from_dttp
        }.to change {
          dttp_degree_qualification.reload.state
        }.from("importable").to("non_importable_missing_institution")
      end
    end
  end
end
