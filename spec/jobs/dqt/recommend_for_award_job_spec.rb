# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RecommendForAwardJob do
    let(:award_date) { nil }
    let(:trainee) { create(:trainee, :recommended_for_award) }

    before do
      enable_features(:integrate_with_dqt)
      allow(RecommendForAward).to receive(:call).with(trainee:).and_return(award_date)
      allow(SlackNotifierService).to receive(:call)
      allow(Survey::ScheduleJob).to receive(:perform_later)
      allow(Trainees::Update).to receive(:call)
    end

    context "we receive an award date" do
      let(:award_date) { Time.zone.today.iso8601 }

      it "updates the trainee awarded_at attribute" do
        expect {
          described_class.perform_now(trainee)
        }.to change(trainee, :awarded_at).to(Time.zone.parse(award_date))
      end

      it "triggers the trainee update job" do
        expect(Trainees::Update).to receive(:call).with(trainee: trainee,
                                                        update_dqt: false)
        described_class.perform_now(trainee)
      end

      it "updates the trainee state to awarded" do
        expect {
          described_class.perform_now(trainee)
        }.to change(trainee, :state).to("awarded")
      end

      context "survey scheduling" do
        before do
          allow(trainee).to receive(:training_route).and_return(training_route)
          allow(trainee.training_route_manager).to receive(:award_type).and_return(award_type)
        end

        context "when trainee is on a non-Assessment Only route and has a QTS award" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
          let(:award_type) { "QTS" }

          it "schedules a survey" do
            expect(Survey::ScheduleJob).to receive(:perform_later).with(trainee: trainee, event_type: :award)
            described_class.perform_now(trainee)
          end
        end

        context "when trainee is on an Assessment Only route" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:assessment_only] }
          let(:award_type) { "QTS" }

          it "does not schedule a survey" do
            expect(Survey::ScheduleJob).not_to receive(:perform_later)
            described_class.perform_now(trainee)
          end
        end

        context "when trainee has an EYTS award" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
          let(:award_type) { "EYTS" }

          it "does not schedule a survey" do
            expect(Survey::ScheduleJob).not_to receive(:perform_later)
            described_class.perform_now(trainee)
          end
        end
      end
    end

    context "we don't receive an award date" do
      it "raises an error" do
        expect {
          described_class.perform_now(trainee)
        }.to raise_error(DqtNoAwardDateError)
      end
    end

    context "with a HESA trainee" do
      let(:award_date) { Time.zone.today.iso8601 }

      before do
        allow(trainee).to receive(:hesa_record?).and_return(true)
      end

      it "sends the trainee to DQT" do
        expect(RecommendForAward).to receive(:call)
        described_class.perform_now(trainee)
      end
    end
  end
end
