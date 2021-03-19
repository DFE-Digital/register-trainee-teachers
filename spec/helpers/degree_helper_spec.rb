# frozen_string_literal: true

require "rails_helper"

describe DegreesHelper do
  include DegreesHelper

  describe "#hesa_degree_types_options" do
    let(:degree_type) { "Bachelor of Arts" }
    let(:degree_abbreviation) { "BA" }
    let(:non_uk_degree_type) { "Unknown" }
    let(:non_uk_degree_types) { %w[Unknown] }

    before do
      stub_const("Dttp::CodeSets::DegreeTypes::NON_UK", [non_uk_degree_type])
      stub_const("Dttp::CodeSets::DegreeTypes::MAPPING", {
        degree_type => { abbreviation: degree_abbreviation },
        non_uk_degree_type => { abbreviation: nil },
      })
    end

    it "iterates over array and prints out correct hesa_degree_types values" do
      expect(hesa_degree_types_options).to match([
        OpenStruct.new(option_name: nil, option_value: nil),
        OpenStruct.new(option_name: "#{degree_type} (#{degree_abbreviation})", option_value: degree_type),
      ])
    end
  end

  describe "#institutions_options" do
    before do
      allow(self).to receive(:institutions).and_return(%w[institution])
    end

    it "iterates over array and prints out correct institutions values" do
      expect(institutions_options.size).to be 2
      expect(institutions_options.first.name).to be_nil
      expect(institutions_options.second.name).to eq "institution"
    end
  end

  describe "#subjects_options" do
    before do
      allow(self).to receive(:subjects).and_return(%w[subject])
    end

    it "iterates over array and prints out correct subjects values" do
      expect(subjects_options.size).to be 2
      expect(subjects_options.first.name).to be_nil
      expect(subjects_options.second.name).to eq "subject"
    end
  end

  describe "#countries_options" do
    before do
      allow(self).to receive(:countries).and_return(%w[country])
    end

    it "iterates over array and prints out correct countries values" do
      expect(countries_options.size).to be 2
      expect(countries_options.first.name).to be_nil
      expect(countries_options.second.name).to eq "country"
    end
  end
end
