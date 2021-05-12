# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCoursesJob do
    include ActiveJob::TestHelper

    let(:course_data) { double }
    let(:provider_data) { double }
    let(:course_payload) { { data: [course_data], included: provider_data, links: { next: nil } } }

    before do
      allow(RetrieveCourses).to receive(:call).and_return(course_payload)
      allow(ImportCourse).to receive(:call).with(course_data: course_data, provider_data: provider_data)

      described_class.perform_now
    end

    context "when the feature flag is turned on", feature_import_courses_from_ttapi: true do
      it "queues up a job to import courses" do
        expect(RetrieveCourses).to have_received(:call).with(request_uri: nil)
        expect(ImportCourse).to have_received(:call).with(course_data: course_data, provider_data: provider_data)
      end
    end
  end
end
