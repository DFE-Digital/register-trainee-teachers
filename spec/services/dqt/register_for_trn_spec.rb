# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RegisterForTrn do
    describe "#call" do
      let(:trainee) { create(:trainee, :with_secondary_course_details, :with_start_date, :with_degree) }
      let(:request_id) { "3f96614b-0373-475b-bf94-119e0d8d9258" }

      before do
        enable_features(:integrate_with_dqt)
        allow(SecureRandom).to receive(:uuid).and_return(request_id)
      end

      context "when the response is a success" do
        let(:dqt_response) {
          {
            "requestId" => request_id,
            "status" => "Completed",
            "trn" => "1234567",
          }
        }

        before do
          allow(Dqt::Client).to receive(:put).and_return(dqt_response)
          described_class.call(trainee:)
        end

        it "registers TRN request with DQT" do
          trn_request = Trs::TrnRequest.last
          expect(trn_request.trainee).to eql(trainee)
          expect(trn_request.request_id).to eql(request_id)
          expect(trn_request.state).to eql("requested")
          expect(trn_request.response).to eql(dqt_response)

          expect(trainee.state).to eql("submitted_for_trn")
        end
      end

      context "when the response is an error" do
        let(:error_message) { "status: 500, body: something went wrong, headers: headers" }

        before do
          allow(Dqt::Client).to receive(:put).and_raise(Client::HttpError, error_message)
          described_class.call(trainee:)
        end

        it "saves a failed TRN request" do
          trn_request = Trs::TrnRequest.last
          expect(trn_request.trainee).to eql(trainee)
          expect(trn_request.request_id).to eql(request_id)
          expect(trn_request.state).to eql("failed")
          expect(trn_request.response).to eql({ "error" => error_message })

          expect(trainee.state).to eql("submitted_for_trn")
        end
      end
    end
  end
end
