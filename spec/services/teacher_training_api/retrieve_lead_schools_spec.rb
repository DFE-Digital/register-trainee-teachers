# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe RetrieveLeadSchools do
    describe "#call" do
      let(:query_params) { "filter[provider_type]=lead_school&sort=name" }
      let(:path) { "/recruitment_cycles/#{Settings.current_recruitment_cycle_year}/providers?#{query_params}" }
      let(:request_url) { "#{Settings.teacher_training_api.base_url}#{path}" }

      before do
        stub_request(:get, request_url).to_return(http_response)
      end

      subject { described_class.call }

      context "when the response is success" do
        let(:http_response) { { status: 200, body: ApiStubs::TeacherTrainingApi.lead_schools.to_json } }

        it "returns the lead school in full" do
          expect(subject).to match(ApiStubs::TeacherTrainingApi.lead_schools)
        end
      end

      it_behaves_like "an http error handler"
    end
  end
end
