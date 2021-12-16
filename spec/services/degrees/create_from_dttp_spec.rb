# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromDttp do
    let(:dttp_trainee) { create(:dttp_trainee) }
    let!(:dttp_degree_qualification) { create(:dttp_degree_qualification, dttp_trainee: dttp_trainee) }
    let(:trainee) { create(:trainee, dttp_trainee: dttp_trainee) }

    subject(:create_from_dttp) { described_class.call(trainee: trainee) }

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

    context "when the degree fails to save" do
      let(:invalid_subject) { "Creative accounting" }
      let(:api_degree_qualification) { create(:api_degree_qualification, _dfe_degreesubjectid_value: invalid_subject) }
      let!(:dttp_degree_qualification) do
        create(
          :dttp_degree_qualification,
          dttp_trainee: dttp_trainee,
          response: api_degree_qualification,
        )
      end

      it "changes the state to non_importable_invalid_data" do
        expect {
          create_from_dttp
        }.to change {
          dttp_degree_qualification.reload.state
        }.from("importable").to("non_importable_invalid_data")
      end
    end
  end
end
