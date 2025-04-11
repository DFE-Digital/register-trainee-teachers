# frozen_string_literal: true

require "rails_helper"

module Trs
  describe UpdateProfessionalStatusJob, feature_integrate_with_trs: true do
    let(:trainee) { create(:trainee, :trn_received) }
    let(:eyts_award_type) { EYTS_AWARD_TYPE }

    describe "#perform" do
      before do
        # Mock the UpdateProfessionalStatus service to prevent real HTTP calls
        allow(UpdateProfessionalStatus).to receive(:call).with(trainee:)
      end

      it "calls the update professional status service" do
        expect(UpdateProfessionalStatus).to receive(:call).with(trainee:).once
        described_class.perform_now(trainee)
      end

      context "when trainee is recommended for award" do
        let(:trainee) { create(:trainee, :trn_received, :recommended_for_award) }
        let(:training_route_manager) { instance_double(TrainingRouteManager, award_type: QTS_AWARD_TYPE) }

        before do
          allow(UpdateProfessionalStatus).to receive(:call).with(trainee:)
          allow(trainee).to receive_messages(assessment_only?: false, training_route_manager: training_route_manager)
          allow(Settings).to receive_message_chain(:qualtrics, :days_delayed, :days).and_return(3.days)
        end

        it "does not award the trainee" do
          expect(trainee).not_to receive(:award_qts!)
          described_class.perform_now(trainee)
        end

        it "schedules a survey" do
          expect { described_class.perform_now(trainee) }.to have_enqueued_job(Survey::SendJob)
        end

        context "when trainee is assessment only" do
          before do
            allow(trainee).to receive(:assessment_only?).and_return(true)
          end

          it "does not schedule a survey" do
            expect { described_class.perform_now(trainee) }.not_to have_enqueued_job(Survey::SendJob)
          end
        end

        context "when trainee has EYTS award type" do
          let(:training_route_manager) { instance_double(TrainingRouteManager, award_type: EYTS_AWARD_TYPE) }

          it "does not schedule a survey" do
            expect { described_class.perform_now(trainee) }.not_to have_enqueued_job(Survey::SendJob)
          end
        end
      end

      context "when the feature flag is disabled", feature_integrate_with_trs: false do
        it "doesn't call the update professional status service" do
          expect(UpdateProfessionalStatus).not_to receive(:call)
          described_class.perform_now(trainee)
        end
      end
    end
  end
end
