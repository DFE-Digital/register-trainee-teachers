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
        let(:trainee) { create(:trainee, :qts_recommended) }

        before do
          allow(UpdateProfessionalStatus).to receive(:call).with(trainee:)
        end

        it "does not award the trainee" do
          expect(trainee).not_to receive(:award_qts!)
          described_class.perform_now(trainee)
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
