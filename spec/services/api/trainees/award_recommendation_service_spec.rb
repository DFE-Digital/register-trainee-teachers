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

      it "returns true", feature_integrate_with_trs: true do
        allow(Trainees::UpdateIttDataInTra).to receive(:call).and_call_original
        allow(Trs::UpdateProfessionalStatusJob).to receive(:perform_later).and_call_original

        success, errors = subject.call(params, trainee)

        expect(success).to be(true)
        expect(errors).to be_blank

        expect(Trainees::UpdateIttDataInTra).to have_received(:call).with(trainee:)
        expect(Trs::UpdateProfessionalStatusJob).to have_received(:perform_later).with(trainee)
        expect(trainee.recommended_for_award?).to be(true)
      end

      it "sets the outcome_date", feature_integrate_with_trs: false do
        expect(trainee.outcome_date).to be_nil

        success, errors = subject.call(params, trainee)

        expect(success).to be(true)
        expect(errors).to be_blank

        expect(trainee.reload.outcome_date).to be_present
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
          expect(errors.full_messages).to contain_exactly("qts_standards_met_date can't be blank")
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
          expect(errors.full_messages).to contain_exactly("qts_standards_met_date can't be blank")
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
          expect(errors.full_messages).to contain_exactly("qts_standards_met_date is invalid")
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
          expect(errors.full_messages).to contain_exactly("qts_standards_met_date must not be in the future")
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
          expect(errors.full_messages).to contain_exactly("qts_standards_met_date must be after itt_start_date")
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
          expect(errors.full_messages).to contain_exactly("state must be selected as trn_received")
          expect(trainee.recommended_for_award?).to be(false)
        end
      end

      context "when trainee has no degrees but is on an undergraduate training route" do
        let(:trainee) { create(:trainee, :trn_received, training_route: :early_years_undergrad) }
        let(:params) do
          {
            qts_standards_met_date: Time.zone.today.iso8601,
          }
        end

        it "returns true" do
          trainee.degrees.destroy_all
          success, _errors = subject.call(params, trainee)

          expect(success).to be(true)
          expect(trainee.recommended_for_award?).to be(true)
        end
      end

      context "when trainee has no degrees and is on a postgraduate training route" do
        let(:trainee) { create(:trainee, :trn_received, training_route: :provider_led_postgrad) }
        let(:params) do
          {
            qts_standards_met_date: Time.zone.today.iso8601,
          }
        end

        it "returns false" do
          trainee.degrees.destroy_all
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("degree_id must be completed before qts_standards_met_date")
          expect(trainee.recommended_for_award?).to be(false)
        end
      end

      context "when trainee has a degree and is on a postgraduate training route" do
        let(:trainee) { create(:trainee, :trn_received, training_route: :provider_led_postgrad) }
        let(:params) do
          {
            qts_standards_met_date: Time.zone.today.iso8601,
          }
        end

        it "returns true" do
          success, _errors = subject.call(params, trainee)

          expect(success).to be(true)
          expect(trainee.recommended_for_award?).to be(true)
        end
      end
    end
  end
end
