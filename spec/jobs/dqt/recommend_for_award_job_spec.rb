# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RecommendForAwardJob do
    let(:award_date) { nil }
    let(:trainee) { create(:trainee, :recommended_for_award) }
    let(:delayed_job) { double(perform_later: true) }
    let(:days_delayed) { 7 }

    before do
      enable_features(:integrate_with_dqt)
      allow(RecommendForAward).to receive(:call).with(trainee:).and_return(award_date)
      allow(SlackNotifierService).to receive(:call)
      allow(Survey::SendJob).to receive(:set).and_return(delayed_job)
      allow(Trainees::Update).to receive(:call)
      allow(Settings).to receive_message_chain(:qualtrics, :days_delayed).and_return(days_delayed)
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

          it "schedules a survey with the configured delay" do
            allow(Survey::SendJob).to receive(:set).with(wait: days_delayed.days).and_return(delayed_job)
            described_class.perform_now(trainee)
            expect(Survey::SendJob).to have_received(:set).with(wait: days_delayed.days)
            expect(delayed_job).to have_received(:perform_later).with(trainee: trainee, event_type: :award)
          end
        end

        context "when trainee is on an Assessment Only route" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:assessment_only] }
          let(:award_type) { "QTS" }

          it "does not schedule a survey" do
            expect(Survey::SendJob).not_to receive(:set)
            described_class.perform_now(trainee)
          end
        end

        context "when trainee has an EYTS award" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
          let(:award_type) { "EYTS" }

          it "does not schedule a survey" do
            expect(Survey::SendJob).not_to receive(:set)
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
