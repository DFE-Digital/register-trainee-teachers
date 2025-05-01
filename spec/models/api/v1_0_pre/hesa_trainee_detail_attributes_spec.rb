# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V10Pre::HesaTraineeDetailAttributes do
  subject { described_class }

  let!(:academic_cycle) { create(:academic_cycle, :current) }

  it { is_expected.to be < Api::V01::HesaTraineeDetailAttributes }

  describe "validations" do
    it "uses the RulesValidator" do
      expect(described_class.validators.map(&:class)).to include(
        Api::V10Pre::HesaTraineeDetailAttributes::RulesValidator,
      )
    end

    describe "funding_method" do
      describe "Postgraduate bursaries require a certain degree and course type (QR.C24053.Student.BURSLEV.20)" do
        let(:trainee_attributes) do
          Api::V10Pre::TraineeAttributes.new(
            training_route: "provider_led_postgraduate",
          )
        end

        subject { described_class.new({ trainee_attributes: trainee_attributes, funding_method: "D", fund_code: "7" }, record_source: "api") }

        context "when funding_method is 'D' (postgraduate bursary)" do
          context "when course subject is declared by a `FundingMethod` record" do
            it "funding_method should be valid" do
              subject.validate
              expect(subject.errors[:funding_method]).to be_blank
            end
          end

          context "when course subject is NOT declared by a `FundingMethod` record" do
            it "funding_method should NOT be valid" do
              subject.validate
              expect(subject.errors[:funding_method]).to be_present
            end
          end
        end
      end
    end
  end
end
