# frozen_string_literal: true

require "rails_helper"

describe DegreesHelper do
  include DegreesHelper

  describe "#degree_type_options" do
    let(:degree_type) { "Bachelor of Arts" }
    let(:degree_abbreviation) { "BA" }
    let(:degree_synonym) { "Bachelors" }

    before do
      stub_const("DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS",
                 DfE::ReferenceData::HardcodedReferenceList.new({
                   SecureRandom.uuid => {
                     name: degree_type,
                     abbreviation: degree_abbreviation,
                     synonyms: [degree_synonym],
                   },
                 }))

      stub_const("Dttp::CodeSets::DegreeTypes::COMMON", [degree_type])
    end

    it "iterates over array and prints out correct degree options" do
      expect(degree_type_options).to match([
        [nil, nil, nil],
        [
          degree_type,
          degree_type,
          {
            "data-append" => "<strong>(#{degree_abbreviation})</strong>",
            "data-boost" => 1.5,
            "data-synonyms" => "#{degree_synonym}|#{degree_abbreviation}",
          },
        ],
      ])
    end
  end

  describe "#institutions_options" do
    let(:institution) { "University College London" }
    let(:synonym) { "UCL" }

    before do
      stub_const("DfE::ReferenceData::Degrees::INSTITUTIONS",
                 DfE::ReferenceData::HardcodedReferenceList.new({
                   SecureRandom.uuid => {
                     name: institution,
                     synonyms: [synonym],
                   },
                 }))
    end

    it "iterates over array and prints out correct institutions options" do
      expect(institutions_options).to match([
        [nil, nil, nil],
        [institution, institution, { "data-synonyms" => synonym }],
      ])
    end
  end

  describe "#subjects_options" do
    let(:degree_subject) { "Mathematics" }
    let(:synonym) { "maths" }

    before do
      stub_const("DfE::ReferenceData::Degrees::SINGLE_SUBJECTS",
                 DfE::ReferenceData::HardcodedReferenceList.new({
                   SecureRandom.uuid => {
                     name: degree_subject,
                     synonyms: [synonym],
                   },
                 }))
    end

    it "iterates over array and prints out correct subjects values" do
      expect(subjects_options).to match([
        [nil, nil, nil],
        [degree_subject, degree_subject, { "data-synonyms" => synonym }],
      ])
    end
  end

  describe "#countries_options" do
    before do
      allow(self).to receive(:countries).and_return(%w[country])
    end

    it "iterates over array and prints out correct countries values" do
      expect(countries_options.size).to be 2
      expect(countries_options.first.value).to be_nil
      expect(countries_options.second.value).to eq "country"
      expect(countries_options.second.text).to eq "Country"
    end
  end
end
