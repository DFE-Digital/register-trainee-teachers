# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe BatchRequest do
    let(:batch_id) { SecureRandom.uuid }
    let(:change_set_id) { SecureRandom.uuid }
    let(:content_id) { SecureRandom.uuid }
    let(:payload) { "payload" }
    let(:expected_url) { "#{Dttp::Client.base_uri}/$batch" }
    let(:expected_headers) { Client.headers.merge("Content-Type" => "multipart/mixed;boundary=batch_#{batch_id}") }

    subject { described_class.new(batch_id: batch_id, change_set_id: change_set_id) }

    before do
      allow(AccessToken).to receive(:fetch).and_return("token")
      allow(SecureRandom).to receive(:uuid).and_return(content_id)
    end

    describe "#add_change_set" do
      it "returns the Content-ID which can be used as reference to other change sets" do
        expect(subject.add_change_set(entity: "contacts", payload: payload)).to eq(content_id)
      end
    end

    describe "#submit" do
      context "multiple change sets" do
        let(:change_set_1) { { entity: "entity1", payload: "test1", content_id: SecureRandom.uuid } }
        let(:change_set_2) { { entity: "entity2", payload: "test2", content_id: SecureRandom.uuid } }

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

        before do
          subject.add_change_set(**change_set_1)
          subject.add_change_set(**change_set_2)
        end

        context "successful" do
          it "sends a batch request with the correct headers and body" do
            stub_request(:post, expected_url).with(headers: expected_headers, body: expected_body)
            subject.submit
          end
        end

        context "unsuccessful" do
          let(:status) { 400 }
          let(:body) { "error" }
          let(:headers) { { foo: "bar" } }

          it "raises an error" do
            stub_request(:post, expected_url).to_return(status: status, body: body, headers: headers)
            expect { subject.submit }.to raise_error(BatchRequest::Error,
                                                     %(body: #{body}, status: #{status}, headers: {"foo"=>["bar"]}))
          end
        end
      end
    end
  end
end
