# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RegisterForTrnJob do
    describe "#perform_now" do
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
      end

      context "when the trainee doesn't have a TRN" do
        let(:trainee) { create(:trainee, :with_secondary_course_details, :with_start_date, :with_degree) }

        it "registers TRN request with DQT" do
          described_class.perform_now(trainee)
          trn_request = Trs::TrnRequest.last
          expect(trn_request.trainee).to eql(trainee)
          expect(trn_request.request_id).to eql(request_id)
          expect(trn_request.state).to eql("requested")
          expect(trn_request.response).to eql(dqt_response)
          expect(trainee.state).to eql("submitted_for_trn")
        end
      end

      context "when the trainee already has a trn" do
        let(:trainee) { create(:trainee, :with_secondary_course_details, :with_start_date, :with_degree, trn: "0123456") }

        it "does not register a TRN request with DQT" do
          described_class.perform_now(trainee)
          expect(Trs::TrnRequest.count).to eq(0)
        end
      end

      context "when the initial request to register the trainee fails" do
        let(:trainee) { create(:trainee, :with_secondary_course_details, :with_start_date, :with_degree) }
        let(:trn_request) { double(failed?: true) }

        before do
          allow(RegisterForTrn).to receive(:call).with(trainee:).and_return(trn_request)
        end

        it "does not register a TRN request with DQT" do
          described_class.perform_now(trainee)
          expect(RetrieveTrnJob).not_to have_received(:perform_later)
        end
      end
    end
  end
end
