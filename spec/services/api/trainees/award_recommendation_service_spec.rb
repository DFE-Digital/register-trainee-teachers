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
        allow(Dqt::RecommendForAwardJob).to receive(:perform_later).and_call_original

        success, errors = subject.call(params, trainee)

        expect(success).to be(true)
        expect(errors).to be_blank

        expect(Dqt::RecommendForAwardJob).to have_received(:perform_later).with(trainee)
        expect(trainee.recommended_for_award?).to be(true)
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
          expect(errors.full_messages).to contain_exactly("QTS standards met date can't be blank")
          expect(trainee.recommended_for_award?).to be(false)
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
          expect(errors.full_messages).to contain_exactly("QTS standards met date can't be blank")
          expect(trainee.recommended_for_award?).to be(false)
        end
      end

      context "when qts_standards_met_date is invalid" do
        let(:trainee) { create(:trainee, :trn_received) }
        let(:params) do
          {
            qts_standards_met_date: "abc",
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("QTS standards met date is invalid")
          expect(trainee.recommended_for_award?).to be(false)
        end
      end

      context "when qts_standards_met_date is in the future" do
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
          expect(trainee.recommended_for_award?).to be(false)
        end
      end

      context "when qts_standards_met_date is before trainee's itt_start_date" do
        let(:trainee) { create(:trainee, :trn_received, :itt_start_date_in_the_future) }
        let(:params) do
          {
            qts_standards_met_date: Time.zone.today.iso8601,
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("QTS standards met date must not be before the ITT start date")
          expect(trainee.recommended_for_award?).to be(false)
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
          expect(trainee.recommended_for_award?).to be(false)
        end
      end
    end
  end
end
