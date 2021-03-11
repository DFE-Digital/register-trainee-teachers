# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe PlacementAssignment do
    describe "#call" do
      let(:trainee) { create(:trainee, dttp_id: :with_placement_assignment) }
      let(:fields) { Dttp::PlacementAssignment::PLACEMENT_ASSIGNMENT_FIELDS }
      let(:path) { "/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})?$select=#{fields.join(',')}" }
      let(:start_date) { 1.year.ago }
      let(:end_date) { Time.zone.now }
      let(:placement_assignment_id) { SecureRandom.uuid }
      let(:provider_id_value) { SecureRandom.uuid }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:get).with(path).and_return(dttp_response)
      end

      context "Placement Assignment sample fields are available" do
        let(:dttp_response) do
          double(code: 200, body: { dfe_programmestartdate: start_date,
                                    dfe_programmeenddate: end_date,
                                    dfe_placementassignmentid: placement_assignment_id,
                                    _dfe_providerid_value: provider_id_value }.to_json)
        end

        it "returns placement assignment JSON ruby hash" do
          expect(described_class.call(trainee: trainee)).to eq(JSON(dttp_response.body))
        end
      end

      context "Placement Assignment sample fields are unavailable" do
        let(:dttp_response) do
          double(code: 200, body: { dfe_programmestartdate: nil,
                                    dfe_programmeenddate: nil,
                                    dfe_placementassignmentid: nil,
                                    _dfe_providerid_value: nil }.to_json)
        end

        it "returns placement assignment fields as nil" do
          expect(described_class.call(trainee: trainee).values).to eq([nil, nil, nil, nil])
        end
      end

      context "HTTP error" do
        let(:status) { 400 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:dttp_response) { double(code: status, body: body, headers: headers) }

        it "raises a HttpError error with the response body as the message" do
          expect(Client).to receive(:get).with(path).and_return(dttp_response)
          expect {
            described_class.call(trainee: trainee)
          }.to raise_error(Dttp::PlacementAssignment::HttpError, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
