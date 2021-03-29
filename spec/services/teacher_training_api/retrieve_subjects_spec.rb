# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe RetrieveSubjects do
    describe "#call" do
      before do
        allow(Client).to receive(:get).with("/subjects").and_return(response)
      end

      context "when the response is success" do
        let(:response) { double(code: 200, body: ApiStubs::TeacherTrainingApi.subjects) }

        it "returns the subjects in full" do
          expect(described_class.call).to eq JSON(response.body)["data"]
        end
      end

      context "when the response is error" do
        let(:status) { 404 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:response) { double(code: status, body: body, headers: headers) }

        it "raises an Error error with the response body as the message" do
          expect {
            described_class.call
          }.to raise_error(TeacherTrainingApi::RetrieveSubjects::Error, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
