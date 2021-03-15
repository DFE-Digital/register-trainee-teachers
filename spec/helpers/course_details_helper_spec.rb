# frozen_string_literal: true

require "rails_helper"

describe CourseDetailsHelper do
  include CourseDetailsHelper

  describe "#course_subjects_options" do
    before do
      allow(self).to receive(:course_subjects).and_return(%w[course_subject])
    end

    it "iterates over array and prints out correct course_subjects values" do
      expect(course_subjects_options.size).to be 2
      expect(course_subjects_options.first.name).to be_nil
      expect(course_subjects_options.second.name).to eq "course_subject"
    end
  end

  describe "#main_age_ranges_options" do
    before do
      allow(self).to receive(:age_ranges).with(option: :main).and_return(%w[main_age_range])
    end

    it "iterates over array and prints out correct main_age_ranges values" do
      expect(main_age_ranges_options).to contain_exactly "main_age_range"
    end
  end

  describe "#additional_age_ranges_options" do
    before do
      allow(self).to receive(:age_ranges).with(option: :additional).and_return(%w[additional_age_range])
    end

    it "iterates over array and prints out correct additional_age_ranges values" do
      expect(additional_age_ranges_options.size).to be 2
      expect(additional_age_ranges_options.first.name).to be_nil
      expect(additional_age_ranges_options.second.name).to eq "additional_age_range"
    end
  end
end
