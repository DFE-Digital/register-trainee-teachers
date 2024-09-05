# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MarkPotentialDuplicateTrainees do
    let(:trainees) { create_list(:trainee, 2) }

    context "when no duplicate trainee records exist" do
      it "creates a record for each trainee" do
        expect{ described_class.call(trainees:) }.to change{ PotentialDuplicateTrainee.count }.by(2)
      end
    end
  end
end
