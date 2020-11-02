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
