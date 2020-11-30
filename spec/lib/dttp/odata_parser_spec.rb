# frozen_string_literal: true

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

        it "raises a DttpIdNotReturned error" do
          expect { subject }.to raise_error(DttpIdNotReturnedError)
        end
      end
    end
  end
end
