# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe TraineeUpdate do
    describe "#call" do
      let(:trainee) { create(:trainee, :completed, :with_secondary_course_details, :with_start_date, :with_degree) }
      let(:dqt_path) { "/v2/teachers/update/#{trainee.trn}?birthDate=#{trainee.date_of_birth.iso8601}" }
      let(:dqt_payload) { Params::TraineeRequest.new(trainee: trainee).to_json }
      let(:dqt_response) { { status: 204 } }

      subject { described_class.call(trainee: trainee) }

      before do
        enable_features(:integrate_with_dqt)
        allow(Client).to receive(:patch).and_return(dqt_response)
      end

      it "sends a PATCH request to update trainee" do
        expect(Client).to receive(:patch).with(dqt_path, body: dqt_payload)
        subject
      end

      it "sets new dqt_update_sha on trainee" do
        expect { subject }.to change(trainee, :dqt_update_sha).to(trainee.sha)
      end
    end
  end
end
