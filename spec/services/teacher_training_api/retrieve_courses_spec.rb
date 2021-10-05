# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe RetrieveCourses do
    describe "#call" do
      let(:path) { "/recruitment_cycles/2021/courses?include=accredited_body,provider&sort=name,provider.provider_name" }
      let(:request_url) { "#{Settings.teacher_training_api.base_url}#{path}" }

      before do
        stub_request(:get, request_url).to_return(http_response)
      end

      subject { described_class.call }

      context "when the response is success" do
        let(:http_response) { { status: 200, body: ApiStubs::TeacherTrainingApi.courses.to_json } }
        let(:expected_courses) { ApiStubs::TeacherTrainingApi.course }

        it "returns the courses in full" do
          expect(subject).to match(ApiStubs::TeacherTrainingApi.courses)
        end
      end

      it_behaves_like "an http error handler"
    end
  end
end
