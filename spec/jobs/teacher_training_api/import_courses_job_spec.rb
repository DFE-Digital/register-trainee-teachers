# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCoursesJob do
    include ActiveJob::TestHelper

    let(:course_data) { double }
    let(:provider_data) { double }
    let(:course_payload) { { data: [course_data], included: provider_data, links: { next: follow_up_uri } } }
    let(:follow_up_uri) { nil }

    describe ".call" do
      before do
        allow(RetrieveCourses).to receive(:call).and_return(course_payload)
        allow(ImportCourse).to receive(:call).with(course_data:, provider_data:)
        allow(described_class).to receive(:perform_later)
        allow(CheckCoursesForMissingProvidersJob).to receive(:perform_later)

        described_class.perform_now
      end

      context "when the feature flag is turned on", feature_import_courses_from_ttapi: true do
        it "queues up a job to import courses" do
          expect(RetrieveCourses).to have_received(:call).with(request_uri: nil)
          expect(ImportCourse).to have_received(:call).with(course_data:, provider_data:)
        end

        context "when there is a follow up uri" do
          let(:follow_up_uri) { "https://www.link.to/thing" }

          it "schedules an ImportCoursesJob" do
            expect(described_class).to have_received(:perform_later)
          end
        end

        context "when there is not a follow up uri" do
          it "schedules a CheckCoursesForMissingProvidersJob" do
            expect(CheckCoursesForMissingProvidersJob).to have_received(:perform_later)
          end
        end
      end
    end
  end
end
