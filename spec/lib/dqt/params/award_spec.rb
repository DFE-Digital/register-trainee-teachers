# frozen_string_literal: true

require "rails_helper"

module Dqt
  module Params
    describe Award do
      let(:trainee) { create(:trainee, :recommended_for_award) }

      subject { described_class.new(trainee: trainee).params }

      describe "#params" do
        it "returns a hash with all required values" do
          expect(subject).to include({
            "ittProviderUkprn" => trainee.provider.ukprn,
            "outcome" => "Pass",
            "assessmentDate" => trainee.outcome_date.iso8601,
          })
        end
      end
    end
  end
end
