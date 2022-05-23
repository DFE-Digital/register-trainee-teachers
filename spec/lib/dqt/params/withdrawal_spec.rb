# frozen_string_literal: true

require "rails_helper"

module Dqt
  module Params
    describe Withdrawal do
      let(:hesa_student) { create(:hesa_student, ukprn: "12345678") }
      let(:trainee) { create(:trainee, :withdrawn, hesa_student: hesa_student) }

      subject { described_class.new(trainee: trainee).params }

      describe "#params" do
        it "returns a hash with all required values" do
          expect(subject).to include({
            "ittProviderUkprn" => "12345678",
            "outcome" => "Withdrawn",
          })
        end
      end
    end
  end
end
