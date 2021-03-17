# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportProviderCoursesJob do
    include ActiveJob::TestHelper

    let(:provider) { create(:provider) }
    let(:courses) { JSON(ApiStubs::TeacherTrainingApi.courses)["data"] }

    before do
      allow(RetrieveCourses).to receive(:call).with(provider: provider).and_return(courses)
      allow(ImportCourse).to receive(:call).with(provider: provider, course: courses.first).and_return(nil)
    end

    context "when the feature flag is turned on", feature_import_courses_from_ttapi: true do
      it "fetches the courses from the TTAPI and calls the creator service" do
        expect(RetrieveCourses).to receive(:call).with(provider: provider)
        expect(ImportCourse).to receive(:call).with(provider: provider, course: courses.first)
        described_class.perform_now(provider)
      end
    end

    context "when the feature flag is turned off", feature_import_courses_from_ttapi: false do
      it "does not do anything" do
        expect(RetrieveCourses).not_to receive(:call).with(provider: provider)
        expect(ImportCourse).not_to receive(:call).with(provider: provider, course: courses.first)
        described_class.perform_now(provider)
      end
    end
  end
end
