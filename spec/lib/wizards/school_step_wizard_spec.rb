# frozen_string_literal: true

require "rails_helper"

module Wizards
  module Schools
    describe StepWizard do
      subject { described_class.new(trainee: trainee) }

      context "when theres a lead school but no employing school" do
        let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_school) }

        it "returns the employing school step" do
          expect(subject.start_point).to eq "/trainees/#{trainee.slug}/employing-schools/edit"
        end
      end
    end
  end
end
