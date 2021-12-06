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

    context "when the trainee does not have a corresponding dttp_trainee" do
      let(:trainee) { create(:trainee) }

      it "raises an error" do
        expect {
          create_from_dttp
        }.to raise_error(described_class::DttpTraineeNotFound)
      end
    end
  end
end
