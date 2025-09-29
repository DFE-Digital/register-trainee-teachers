# frozen_string_literal: true

require "rails_helper"

module Trs
  describe UpdateProfessionalStatusJob, feature_integrate_with_trs: true do
    let(:trainee) { create(:trainee) }

    describe "#perform" do
      before do
        allow(UpdateProfessionalStatus).to receive(:call).with(trainee:)
      end

      it "calls the update professional status service" do
        expect(UpdateProfessionalStatus).to receive(:call).with(trainee:).once
        described_class.perform_now(trainee)
      end

      it "does not schedule a survey" do
        expect { described_class.perform_now(trainee) }.not_to have_enqueued_job(Survey::SendJob)
      end

      context "when trainee is recommended for award" do
        let(:outcome_date) { Time.zone.today }
        let(:trainee) { create(:trainee, :qts_recommended, outcome_date:) }

        before do
          allow(UpdateProfessionalStatus).to receive(:call).with(trainee:)
        end

        it "awards the trainee with the outcome date" do
          expect(trainee).to receive(:award_qts!).with(outcome_date)
          described_class.perform_now(trainee)
        end

        it "updates the trainee without calling DQT again" do
          allow(Trainees::Update).to receive(:call)
          expect(Trainees::Update).to receive(:call).with(trainee: trainee, update_trs: false)
          described_class.perform_now(trainee)
        end

        it "transitions the trainee to awarded state" do
          described_class.perform_now(trainee)
          expect(trainee.reload.state).to eq("awarded")
          expect(trainee.awarded_at.to_date).to eq(outcome_date.to_date)
        end

        context "when trainee has no outcome date" do
          let(:trainee) { create(:trainee, :qts_recommended, outcome_date: nil) }

          it "does not award the trainee" do
            expect(trainee).not_to receive(:award_qts!)
            described_class.perform_now(trainee)
            expect(trainee.reload.state).to eq("recommended_for_award")
          end
        end

        it "schedules a survey" do
          expect { described_class.perform_now(trainee) }.to have_enqueued_job(Survey::SendJob)
        end

        context "when trainee is assessment only" do
          let(:trainee) { create(:trainee, :assessment_only) }

          it "does not schedule a survey" do
            expect { described_class.perform_now(trainee) }.not_to have_enqueued_job(Survey::SendJob)
          end
        end

        context "when trainee has EYTS award type" do
          let(:trainee) { create(:trainee, :eyts_awarded) }

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
