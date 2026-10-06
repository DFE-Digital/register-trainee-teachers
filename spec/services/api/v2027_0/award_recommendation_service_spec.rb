# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20270::AwardRecommendationService do
  subject { described_class }

  describe "::call" do
    describe "success" do
      let(:trainee) { create(:trainee, :trn_received, :with_employing_school) }
      let(:params) do
        {
          qts_or_eyts_requirements_met_date: Time.zone.today.iso8601,
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
      context "when qts_or_eyts_requirements_met_date is nil" do
        let(:trainee) { create(:trainee, :trn_received, :with_employing_school) }
        let(:params) do
          {
            qts_or_eyts_requirements_met_date: nil,
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("qts_or_eyts_requirements_met_date can't be blank. Enter a date the trainee met the QTS or EYTS requirements.")
          expect(trainee.recommended_for_award?).to be(false)
        end
      end

      context "when trainee has no degrees and is on a postgraduate training route" do
        let(:trainee) { create(:trainee, :trn_received, :with_placements, training_route: :provider_led_postgrad) }
        let(:params) do
          {
            qts_or_eyts_requirements_met_date: Time.zone.today.iso8601,
          }
        end

        it "returns false" do
          trainee.degrees.destroy_all
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("degree_id must be completed before qts_or_eyts_requirements_met_date")
          expect(trainee.recommended_for_award?).to be(false)
        end
      end

      context "when trainee on assessment_only route has no employing school" do
        let(:trainee) { create(:trainee, :trn_received, training_route: :assessment_only) }
        let(:params) do
          {
            qts_or_eyts_requirements_met_date: Time.zone.today.iso8601,
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("employing_school_urn must be completed before qts_or_eyts_requirements_met_date")
          expect(trainee.recommended_for_award?).to be(false)
        end
      end
    end
  end
end
