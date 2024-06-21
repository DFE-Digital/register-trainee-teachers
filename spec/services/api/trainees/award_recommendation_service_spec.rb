# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Trainees::AwardRecommendationService do
  subject { described_class }

  describe "::call" do
    describe "success" do
      let(:trainee) { create(:trainee, :trn_received) }
      let(:params) do
        {
          qts_standards_met_date: Time.zone.today.iso8601,
        }
      end

      it "returns true" do
        allow(OutcomeDateForm).to receive(:new).and_call_original
        allow(Dqt::RecommendForAwardJob).to receive(:perform_later).and_call_original

        success, errors = subject.call(params, trainee)

        expect(success).to be(true)
        expect(errors).to be_blank

        expect(OutcomeDateForm).to have_received(:new).with(trainee, update_dqt: false)
        expect(Dqt::RecommendForAwardJob).to have_received(:perform_later).with(trainee)

        expect(trainee.reload.recommended_for_award?).to be(true)
      end
    end

    describe "failure" do
      context "when qts_standards_met_date is nil" do
        let(:trainee) { create(:trainee, :trn_received) }
        let(:params) do
          {
            qts_standards_met_date: nil,
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("Qts standards met date can't be blank")
        end
      end

      context "when qts_standards_met_date is empty" do
        let(:trainee) { create(:trainee, :trn_received) }
        let(:params) do
          {
            qts_standards_met_date: "",
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("Qts standards met date can't be blank")
        end
      end

      context "when outcome_date is invalid" do
        let(:trainee) { create(:trainee, :trn_received) }
        let(:params) do
          {
            qts_standards_met_date: "123",
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("Qts standards met date is invalid")
        end
      end

      context "when trainee's state is not trn_received" do
        let(:trainee) { create(:trainee, :submitted_for_trn) }
        let(:params) do
          {
            qts_standards_met_date: Time.zone.today.iso8601,
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("Trainee state is invalid must be [trn_received]")
        end
      end

      context "when outcome_date_form is invalid" do
        let(:trainee) { create(:trainee, :trn_received) }
        let(:params) do
          {
            qts_standards_met_date: Time.zone.tomorrow.iso8601,
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("QTS standards met date must be in the past")
        end
      end
    end
  end
end
