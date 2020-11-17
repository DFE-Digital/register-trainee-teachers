# frozen_string_literal: true

require "rails_helper"

describe ProgrammeDetailsHelper do
  include ProgrammeDetailsHelper

  describe "#programme_subjects_options" do
    before do
      allow(self).to receive(:programme_subjects).and_return(%w[programme_subject])
    end

    it "iterates over array and prints out correct programme_subjects values" do
      expect(programme_subjects_options.size).to be 2
      expect(programme_subjects_options.first.name).to be_nil
      expect(programme_subjects_options.second.name).to eq "programme_subject"
    end
  end

  describe "#main_age_ranges_options" do
    before do
      allow(self).to receive(:age_ranges).with(options: :main).and_return(%w[main_age_range])
    end

    it "iterates over array and prints out correct main_age_ranges values" do
      expect(main_age_ranges_options).to contain_exactly "main_age_range"
    end
  end

  describe "#additional_age_ranges_options" do
    before do
      allow(self).to receive(:age_ranges).with(options: :additional).and_return(%w[additional_age_range])
    end

    it "iterates over array and prints out correct additional_age_ranges values" do
      expect(additional_age_ranges_options.size).to be 2
      expect(additional_age_ranges_options.first.name).to be_nil
      expect(additional_age_ranges_options.second.name).to eq "additional_age_range"
    end
  end
end
