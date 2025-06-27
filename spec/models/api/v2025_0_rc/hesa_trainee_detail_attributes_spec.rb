# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20250Rc::HesaTraineeDetailAttributes do
  subject { described_class }

  let!(:academic_cycle) { create(:academic_cycle, :current) }

  describe "validations" do
    it "uses the RulesValidator" do
      expect(described_class.validators.map(&:class)).to include(
        Api::V20250Rc::HesaTraineeDetailAttributes::RulesValidator,
      )
    end

    describe "funding_method" do
      describe "Postgraduate bursaries require a certain degree and course type (QR.C24053.Student.BURSLEV.20)" do
        let(:course_subject_one) { "mathematics" }
        let(:trainee_attributes) do
          Api::V20250Rc::TraineeAttributes.new(
            training_route: :provider_led_postgrad,
            course_subject_one: course_subject_one,
            fund_code: Api::V20250Rc::HesaTraineeDetailAttributes::Rules::FundCode::FUND_CODE,
          )
        end

        subject { described_class.new({ trainee_attributes: trainee_attributes, funding_method: "D", fund_code: "7" }, record_source: "api") }

        context "when funding_method is 'D' (postgraduate bursary)" do
          context "when course subject is declared by a `FundingMethod` record" do
            let(:allocation_subject) { create(:allocation_subject) }
            let!(:subject_specialism) do
              create(
                :subject_specialism,
                allocation_subject: allocation_subject,
                name: course_subject_one,
              )
            end
            let(:funding_rule) do
              create(
                :funding_method,
                training_route: :provider_led_postgrad,
                funding_type: :bursary,
                academic_cycle: academic_cycle,
              )
            end
            let!(:funding_method_subject) do
              create(
                :funding_method_subject,
                funding_method: funding_rule,
                allocation_subject: allocation_subject,
              )
            end

            it "funding_method should be valid" do
              subject.validate
              expect(subject.errors[:funding_method]).to be_blank
            end
          end

          context "when course subject is NOT declared by a `FundingMethod` record" do
            it "funding_method should NOT be valid" do
              subject.validate
              expect(subject.errors[:funding_method]).to be_present
              expect(subject.errors[:funding_method]).to include(
                "training route 'provider_led_postgrad' and subject code 'mathematics' are not eligible for 'bursary' in academic cycle '#{academic_cycle.label}'",
              )
            end
          end
        end
      end
    end

    describe "fund_code" do
      let(:trainee_attributes) do
        Api::V20250Rc::TraineeAttributes.new(
          training_route: :provider_led_postgrad,
          course_subject_one: "mathematics",
          fund_code: Api::V20250Rc::HesaTraineeDetailAttributes::Rules::FundCode::FUND_CODE,
        )
      end

      subject { described_class.new({ trainee_attributes: trainee_attributes, funding_method: "D", fund_code: "7" }, record_source: "api") }

      context "for an unfunded training route" do
        it "fund_code should NOT be valid" do
          subject.validate
          expect(subject.errors[:fund_code]).to include("is not valid for this trainee")
        end
      end
    end
  end
end
