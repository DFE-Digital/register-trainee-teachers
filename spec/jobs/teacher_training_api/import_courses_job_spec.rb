# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportCoursesJob do
    include ActiveJob::TestHelper

    let(:subject) { double }

    before do
      allow(ImportSubject).to receive(:call).with(subject: subject).and_return(true)
      allow(RetrieveSubjects).to receive(:call).and_return([subject])

      create_list(:provider, 2)
      described_class.perform_now
    end

    context "when the feature flag is turned on", feature_import_courses_from_ttapi: true do
      it "retrieves all the subjects" do
        expect(RetrieveSubjects).to have_received(:call)
        expect(ImportSubject).to have_received(:call).with(subject: subject)
      end

      it "queues up a job to import courses for each provider" do
        Provider.all.each do |provider|
          expect(ImportProviderCoursesJob).to have_been_enqueued.with(provider)
        end
      end
    end

    context "when the feature flag is turned off", feature_import_courses_from_ttapi: false do
      it "doesn't queue up anything" do
        Provider.all.each do |provider|
          expect(ImportProviderCoursesJob).not_to have_been_enqueued.with(provider)
        end
      end
    end
  end
end
