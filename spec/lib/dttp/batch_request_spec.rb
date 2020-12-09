# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe Dttp::BatchRequest do
    let(:batch_id) { SecureRandom.uuid }
    let(:change_set_id) { SecureRandom.uuid }
    let(:content_id) { SecureRandom.uuid }
    let(:payload) { "payload" }

    subject { described_class.new(batch_id: batch_id, change_set_id: change_set_id) }

    describe "#add_change_set" do
      before do
        allow(SecureRandom).to receive(:uuid).and_return(content_id)
      end

      it "returns the Content-ID which can be used as reference to other change sets" do
        expect(subject.add_change_set(entity: "contacts", payload: payload)).to eq(content_id)
      end
    end

    describe "#submit" do
      let(:change_set_1) { { entity: "entity1", payload: "test1", content_id: SecureRandom.uuid } }
      let(:change_set_2) { { entity: "entity2", payload: "test2", content_id: SecureRandom.uuid } }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:post).and_return(dttp_response)
      end

      context "multiple change sets" do
        before do
          subject.add_change_set(**change_set_1)
          subject.add_change_set(**change_set_2)
        end

        context "unsuccessful" do
          let(:error_body) { "error" }
          let(:dttp_response) { double(code: 400, body: error_body) }

          it "raises an error" do
            expect { subject.submit }.to raise_error(BatchRequest::Error, error_body)
          end
        end

        context "successful" do
          let(:dttp_response) { double(code: 200) }
          let(:expected_headers) { { "Content-Type" => "multipart/mixed;boundary=batch_#{batch_id}" } }

          let(:expected_body) do
            <<~BODY
              --batch_#{batch_id}
              Content-Type: multipart/mixed;boundary=changeset_#{change_set_id}

              --changeset_#{change_set_id}
              Content-Type: application/http
              Content-Transfer-Encoding: binary
              Content-ID: #{change_set_1[:content_id]}

              POST #{Dttp::Client.base_uri}/#{change_set_1[:entity]} HTTP/1.1
              Content-Type: application/json;odata.metadata=minimal

              #{change_set_1[:payload]}

              --changeset_#{change_set_id}
              Content-Type: application/http
              Content-Transfer-Encoding: binary
              Content-ID: #{change_set_2[:content_id]}

              POST #{Dttp::Client.base_uri}/#{change_set_2[:entity]} HTTP/1.1
              Content-Type: application/json;odata.metadata=minimal

              #{change_set_2[:payload]}

              --changeset_#{change_set_id}--
              --batch_#{batch_id}--
            BODY
          end

          it "sends a batch request with the correct headers and body" do
            expect(Dttp::Client).to receive(:post).with("/$batch", body: expected_body, headers: expected_headers)
            subject.submit
          end
        end
      end
    end
  end
end
