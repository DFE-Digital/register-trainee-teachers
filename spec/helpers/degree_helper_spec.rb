require "rails_helper"

describe DegreesHelper do
  include DegreesHelper

  describe "#hesa_degree_types_options" do
    before do
      allow(self).to receive(:hesa_degree_types).and_return(%w[hesa_degree_type])
    end

    it "iterates over array and prints out correct hesa_degree_types values" do
      expect(hesa_degree_types_options.size).to be 2
      expect(hesa_degree_types_options.first.name).to be_nil
      expect(hesa_degree_types_options.second.name).to eq "hesa_degree_type"
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

  describe "#degree_subjects_options" do
    before do
      allow(self).to receive(:degree_subjects).and_return(%w[degree_subject])
    end

    it "iterates over array and prints out correct degree_subjects values" do
      expect(degree_subjects_options.size).to be 2
      expect(degree_subjects_options.first.name).to be_nil
      expect(degree_subjects_options.second.name).to eq "degree_subject"
    end
  end

  describe "#degree_countries_options" do
    before do
      allow(self).to receive(:degree_countries).and_return(%w[degree_country])
    end

    it "iterates over array and prints out correct degree_countries values" do
      expect(degree_countries_options.size).to be 2
      expect(degree_countries_options.first.name).to be_nil
      expect(degree_countries_options.second.name).to eq "degree_country"
    end
  end
end
