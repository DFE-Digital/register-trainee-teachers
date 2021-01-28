# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe OdataParser do
    describe ".entity_id" do
      let(:trainee_id) { 1 }
      let(:response) { double(body: "", headers: headers) }
      let(:entity_id) { SecureRandom.uuid }
      let(:headers) do
        {
          "odata-version" => "4.0",
          "odata-entityid" => "https://example.com/api/data/v9.0/contacts(#{entity_id})",
        }
      end

      subject { described_class.entity_id(trainee_id, response) }

      it "returns the entity ID from the response headers" do
        expect(subject).to eq(entity_id)
      end

      context "headers don't have an entity ID" do
        let(:headers) { {} }
        let(:response) { double(body: { error: { message: "something went wrong" } }, headers: headers) }

        it "raises a DttpIdNotReturned error" do
          expect { subject }.to raise_error(DttpIdNotReturnedError)
        end
      end
    end

    describe ".entity_ids" do
      let(:batch_response) do
        %(--batchresponse_be1335fd-d817-4407-8724-4e5aa6ac88a1
          Content-Type: multipart/mixed; boundary=changesetresponse_2c01fd6c-823c-418c-9aed-6aba0db0dcbd

          --changesetresponse_2c01fd6c-823c-418c-9aed-6aba0db0dcbd
          Content-Type: application/http
          Content-Transfer-Encoding: binary
          Content-ID: 06910a13-3875-4d7b-9dbf-d3d651a18e45

          HTTP/1.1 204 No Content
          OData-Version: 4.0
          Location: https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/contacts(243fc7f1-6035-eb11-a813-000d3ada6b1f)
          OData-EntityId: https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/contacts(243fc7f1-6035-eb11-a813-000d3ada6b1f)


          --changesetresponse_2c01fd6c-823c-418c-9aed-6aba0db0dcbd
          Content-Type: application/http
          Content-Transfer-Encoding: binary
          Content-ID: 939906f2-bbe3-4080-9ed0-1aa6660dfabb

          HTTP/1.1 204 No Content
          OData-Version: 4.0
          Location: https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/dfe_placementassignments(273fc7f1-6035-eb11-a813-000d3ada6b1f)
          OData-EntityId: https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/dfe_placementassignments(273fc7f1-6035-eb11-a813-000d3ada6b1f)

          --changesetresponse_2c01fd6c-823c-418c-9aed-6aba0db0dcbd--
          --batchresponse_be1335fd-d817-4407-8724-4e5aa6ac88a1--

          --changesetresponse_bce10c8d-d29e-45b4-942e-5a6d5a06305f
          Content-Type: application/http
          Content-Transfer-Encoding: binary
          Content-ID: 5dc36062-2080-4515-b1cf-cff69726389d

          HTTP/1.1 204 No Content
          OData-Version: 4.0
          Location: https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/dfe_degreequalifications(62ebc247-3a57-eb11-a812-000d3ada6b1f)
          OData-EntityId: https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/dfe_degreequalifications(62ebc247-3a57-eb11-a812-000d3ada6b1f)


          --changesetresponse_bce10c8d-d29e-45b4-942e-5a6d5a06305f
          Content-Type: application/http
          Content-Transfer-Encoding: binary
          Content-ID: 2f645f14-bae8-4b5f-93df-b76d4a774a8c

          HTTP/1.1 204 No Content
          OData-Version: 4.0
          Location: https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/dfe_degreequalifications(67ebc247-3a57-eb11-a812-000d3ada6b1f)
          OData-EntityId: https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/dfe_degreequalifications(67ebc247-3a57-eb11-a812-000d3ada6b1f))
      end

      subject { described_class.entity_ids(batch_response: batch_response) }

      it "returns a hash of key/value pairs where the key is the entity name and the value the entity ID" do
        expect(subject).to include({
          "contacts" => [{ content_id: "06910a13-3875-4d7b-9dbf-d3d651a18e45", entity_id: "243fc7f1-6035-eb11-a813-000d3ada6b1f" }],
          "dfe_placementassignments" => [{ content_id: "939906f2-bbe3-4080-9ed0-1aa6660dfabb", entity_id: "273fc7f1-6035-eb11-a813-000d3ada6b1f" }],
          "dfe_degreequalifications" => [
            { content_id: "5dc36062-2080-4515-b1cf-cff69726389d", entity_id: "62ebc247-3a57-eb11-a812-000d3ada6b1f" },
            { content_id: "2f645f14-bae8-4b5f-93df-b76d4a774a8c", entity_id: "67ebc247-3a57-eb11-a812-000d3ada6b1f" },
          ],
        })
      end
    end
  end
end
