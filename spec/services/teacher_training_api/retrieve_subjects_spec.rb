# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe RetrieveSubjects do
    describe "#call" do
      let(:path) { "/subjects" }
      let(:request_url) { "#{Settings.teacher_training_api.base_url}#{path}" }

      before do
        stub_request(:get, request_url).to_return(http_response)
      end

      subject { described_class.call }

      context "when the response is success" do
        let(:http_response) { { status: 200, body: ApiStubs::TeacherTrainingApi.subjects.to_json } }

        it "returns the subjects in full" do
          expect(subject).to eq(ApiStubs::TeacherTrainingApi.subjects[:data])
        end
      end

      it_behaves_like "an http error handler"
    end
  end
end
