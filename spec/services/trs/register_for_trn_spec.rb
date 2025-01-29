# frozen_string_literal: true

require "rails_helper"

module Trs
  describe RegisterForTrn do
    describe "#call" do
      let(:trainee) { create(:trainee, :with_secondary_course_details, :with_start_date, :with_degree) }
      let(:request_id) { "229d4752-f7a0-4208-a3b9-41aade0743ac" }

      before do
        enable_features(:integrate_with_trs)
        allow(SecureRandom).to receive(:uuid).and_return(request_id)
      end

      context "when the response is a success" do
        let(:trs_response) {
          {
            "requestId" => request_id,
            "status" => "Completed",
            "trn" => "1234567",
          }
        }

        before do
          allow(Trs::Client).to receive(:post).and_return(trs_response)
          described_class.call(trainee:)
        end

        it "registers TRN request with TRS" do
          trn_request = ::Dqt::TrnRequest.last
          expect(trn_request.trainee).to eql(trainee)
          expect(trn_request.request_id).to eql(request_id)
          expect(trn_request.state).to eql("requested")
          expect(trn_request.response).to eql(trs_response)

          expect(trainee.state).to eql("submitted_for_trn")
        end
      end

      context "when the response is an error" do
        let(:error_message) { "status: 500, body: something went wrong, headers: headers" }

        before do
          allow(Trs::Client).to receive(:post).and_raise(Client::HttpError, error_message)
          described_class.call(trainee:)
        end

        it "saves a failed TRN request" do
          trn_request = ::Dqt::TrnRequest.last
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
