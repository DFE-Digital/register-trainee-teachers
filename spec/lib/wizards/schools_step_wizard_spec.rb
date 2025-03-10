# frozen_string_literal: true

require "rails_helper"

module Wizards
  describe SchoolsStepWizard do
    subject { described_class.new(trainee:) }

    describe "#start_point" do
      context "when theres no lead partner or employing school" do
        let(:trainee) { create(:trainee, :school_direct_salaried) }

        it "returns the lead school step" do
          expect(subject.start_point).to eq "/trainees/#{trainee.slug}/lead-partners/edit"
        end
      end

      context "when theres a lead partner but no employing school" do
        let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_partner) }

        it "returns the employing school step" do
          expect(subject.start_point).to eq "/trainees/#{trainee.slug}/employing-schools/edit"
        end
      end

      context "when all the forms are complete" do
        let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_partner, :with_employing_school) }

        it "returns nil" do
          expect(subject.start_point).to be_nil
        end
      end
    end
  end
end
