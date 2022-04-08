# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RegisterForTrnJob do
    describe "#perform_now" do
      let(:trainee) { create(:trainee, :with_secondary_course_details, :with_start_date, :with_degree) }
      let(:request_id) { "3f96614b-0373-475b-bf94-119e0d8d9258" }
      let(:dqt_response) {
        {
          "requestId" => request_id,
          "status" => "Completed",
          "trn" => "1234567",
        }
      }

      before do
        enable_features(:integrate_with_dqt)
        allow(SecureRandom).to receive(:uuid).and_return(request_id)
        allow(Dqt::Client).to receive(:put).and_return(dqt_response)
        allow(RetrieveTrnJob).to receive(:perform_later)
        described_class.perform_now(trainee)
      end

      it "registers TRN request with DQT" do
        trn_request = TrnRequest.last
        expect(trn_request.trainee).to eql(trainee)
        expect(trn_request.request_id).to eql(request_id)
        expect(trn_request.state).to eql("requested")
        expect(trn_request.response).to eql(dqt_response)

        expect(trainee.state).to eql("submitted_for_trn")
      end

      context "with a HESA trainee" do
        before do
          allow(SlackNotifierService).to receive(:call)
          allow(trainee).to receive(:hesa_record?).and_return(true)
        end

        it "reports to Slack" do
          expect(SlackNotifierService).to receive(:call).with(message: "Trainee id: #{trainee.id}, slug: #{trainee.slug} has been registered for TRN but is a HESA trainee", username: "Register Trainee Teachers: Job Failure")
          described_class.perform_now(trainee)
        end

        it "doesn't send the trainee to DQT" do
          expect(RecommendForAward).not_to receive(:call)
          described_class.perform_now(trainee)
        end
      end
    end
  end
end
