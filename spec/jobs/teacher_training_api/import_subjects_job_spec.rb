# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportSubjectsJob do
    include ActiveJob::TestHelper

    let(:course_subject) { double }
    let(:course_attributes) { double }

    before do
      allow(ImportSubject).to receive(:call).with(subject: course_subject).and_return(true)
      allow(RetrieveSubjects).to receive(:call).and_return([course_subject])

      described_class.perform_now
    end

    context "when the feature flag is turned on", feature_import_courses_from_ttapi: true do
      it "retrieves all the subjects" do
        expect(RetrieveSubjects).to have_received(:call)
        expect(ImportSubject).to have_received(:call).with(subject: course_subject)
      end
    end
  end
end
