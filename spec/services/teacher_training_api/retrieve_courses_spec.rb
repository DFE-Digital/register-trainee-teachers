# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe RetrieveCourses do
    describe "#call" do
      let(:path) { "/courses?filter[findable]=true&include=accredited_body,provider" }

      before do
        allow(Client).to receive(:get).with(path).and_return(response)
      end

      context "when the response is success" do
        let(:response) { double(code: 200, body: ApiStubs::TeacherTrainingApi.courses.to_json) }
        let(:expected_courses) { ApiStubs::TeacherTrainingApi.course }

        it "returns the courses in full" do
          expect(described_class.call).to match(ApiStubs::TeacherTrainingApi.courses)
        end
      end

      context "when the response is error" do
        let(:status) { 404 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:response) { double(code: status, body: body, headers: headers) }

        it "raises a Error error with the response body as the message" do
          expect {
            described_class.call
          }.to raise_error(TeacherTrainingApi::RetrieveCourses::Error, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
