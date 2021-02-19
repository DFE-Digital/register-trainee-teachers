# frozen_string_literal: true

require "rails_helper"

module Trns
  describe SubmissionChecker do
    describe ".call" do
      let(:full_trainee) do
        create(
          :trainee,
          :with_start_date,
          :with_programme_details,
          ethnic_background: "some background",
          nationalities: [create(:nationality)],
          disabilities: [create(:disability)],
          degrees: [create(:degree, :uk_degree_with_details)],
        )
      end

      subject { described_class.call(trainee: full_trainee) }

      context "when all sections are valid and complete" do
        before do
          SubmissionChecker::VALIDATORS.each do |validator_hash|
            allow(full_trainee.progress).to receive(validator_hash[:progress_key]).and_return(true)
          end

          subject.call
        end

        it "is successful" do
          expect(subject).to be_successful
        end
      end

      context "when any section is invalid or incomplete" do
        before do
          subject.call
        end

        it "is unsuccessful" do
          expect(subject).to_not be_successful
        end
      end
    end
  end
end
