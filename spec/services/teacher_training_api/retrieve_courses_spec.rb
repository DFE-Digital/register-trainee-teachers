# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe RetrieveCourses do
    describe "#call" do
      let(:provider) { create(:provider) }
      let(:path) { "/recruitment_cycles/2021/providers/#{provider.code}/courses" }

      before do
        allow(Client).to receive(:get).with(path).and_return(response)
      end

      context "when the response is success" do
        let(:response) { double(code: 200, body: ApiStubs::TeacherTrainingApi.courses) }

        it "returns the courses in full" do
          expect(described_class.call(provider: provider)).to eq JSON(response.body)["data"]
        end
      end

      context "when the response is error" do
        let(:status) { 404 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:response) { double(code: status, body: body, headers: headers) }

        it "raises a HttpError error with the response body as the message" do
          expect {
            described_class.call(provider: provider)
          }.to raise_error(TeacherTrainingApi::RetrieveCourses::HttpError, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
