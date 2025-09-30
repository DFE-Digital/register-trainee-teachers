# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RetrieveTrn do
    let(:trainee) { create(:trainee, :with_secondary_course_details, :with_start_date, :with_degree) }
    let(:request_id) { SecureRandom.uuid }
    let(:trn) { "XXX123" }
    let(:dqt_response) {
      {
        "requestId" => request_id,
        "status" => "Completed",
        "trn" => trn,
      }
    }
    let(:trn_request) { create(:trs_trn_request, trainee: trainee, request_id: request_id, response: dqt_response) }

    describe "#call" do
      before do
        enable_features(:integrate_with_dqt)
        allow(Dqt::Client).to receive(:get).and_return(dqt_response)
      end

      subject { described_class.call(trn_request:) }

      context "TRN is available" do
        it "returns the TRN value" do
          expect(subject).to eq(trn)
        end
      end

      context "TRN is not available" do
        let(:trn) { nil }

        it "returns emtpy trn" do
          expect(subject).to be_nil
        end
      end
    end
  end
end
