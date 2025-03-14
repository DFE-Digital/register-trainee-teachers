# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe SampleTraineeDataGenerator do
    subject { described_class.call(file_name:, count:, with_invalid_records:, with_incomplete_records:, with_placement:, with_degree:) }

    let(:file_name) { "tmp/test_trainees.csv" }
    let(:with_invalid_records) { false }
    let(:with_incomplete_records) { false }
    let(:with_placement) { false }
    let(:with_degree) { false }
    let(:count) { 1 }

    after do
      FileUtils.rm_f(file_name)
    end

    describe "#call" do
      context "with valid data" do
        it "generates a CSV file" do
          subject
          expect(File.exist?(file_name)).to be true
        end
      end

      context "with valid degrees and placements" do
        let(:with_placement) { true }
        let(:with_degree) { true }

        it "generates a CSV file" do
          subject
          expect(File.exist?(file_name)).to be true
        end
      end

      context "with invalid data" do
        let(:with_invalid_records) { true }

        it "generates a CSV file" do
          subject
          expect(File.exist?(file_name)).to be true
        end
      end

      context "with incomplete data" do
        let(:with_incomplete_records) { true }

        it "generates a CSV file" do
          subject
          expect(File.exist?(file_name)).to be true
        end
      end
    end
  end
end
