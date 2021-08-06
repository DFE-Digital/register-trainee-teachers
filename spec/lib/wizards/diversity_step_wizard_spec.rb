# frozen_string_literal: true

require "rails_helper"

module Wizards
  describe DiversitiesStepWizard do
    subject { described_class.new(trainee: trainee) }

    describe "#start_point" do
      context "when diversity is disclosed and the rest of the form incomplete" do
        let(:trainee) { create(:trainee, :diversity_disclosed) }

        it "returns the ethnic group step" do
          expect(subject.start_point).to eq "/trainees/#{trainee.slug}/diversity/ethnic-group/edit"
        end
      end

      context "when diversity is disclosed, ethnic group chosen and the rest of the form incomplete" do
        let(:trainee) { create(:trainee, :diversity_disclosed, :with_ethnic_group) }

        it "returns the ethnic background step" do
          expect(subject.start_point).to eq "/trainees/#{trainee.slug}/diversity/ethnic-background/edit"
        end
      end

      context "when diversity is disclosed, ethnic group and background chosen and the rest of the form incomplete" do
        let(:trainee) { create(:trainee, :diversity_disclosed, :with_ethnic_group, :with_ethnic_background, disability_disclosure: nil) }

        it "returns the disability disclosure step" do
          expect(subject.start_point).to eq "/trainees/#{trainee.slug}/diversity/disability-disclosure/edit"
        end
      end

      context "disability is missing" do
        let(:trainee) { create(:trainee, :diversity_disclosed, :with_ethnic_group, :with_ethnic_background, :disabled) }

        it "returns the disability disclosure step" do
          expect(subject.start_point).to eq "/trainees/#{trainee.slug}/diversity/disabilities/edit"
        end
      end

      context "all forms complete" do
        let(:trainee) { create(:trainee, :with_diversity_information) }

        it "returns nil" do
          expect(subject.start_point).to eq nil
        end
      end
    end
  end
end
