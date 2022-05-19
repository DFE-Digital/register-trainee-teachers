# frozen_string_literal: true

require "rails_helper"

module Dqt
  module Params
    describe Withdrawal do
      let(:trainee) { create(:trainee, :withdrawn) }

      subject { described_class.new(trainee: trainee).params }

      describe "#params" do
        it "returns a hash with all required values" do
          expect(subject).to include({
            "outcome" => "Withdrawn",
          })
        end
      end
    end
  end
end
