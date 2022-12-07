# frozen_string_literal: true

require "rails_helper"

describe DegreesHelper do
  include DegreesHelper

  describe "#degree_type_options" do
    let(:degree_type) { "Bachelor of Arts" }
    let(:degree_abbreviation) { "BA" }
    let(:match_synonym) { "Bachelors" }
    let(:suggestion_synonym) { "Bachelor" }

    before do
      stub_const("Degrees::DfEReference::TYPES",
                 DfE::ReferenceData::HardcodedReferenceList.new({
                   SecureRandom.uuid => {
                     name: degree_type,
                     abbreviation: degree_abbreviation,
                     match_synonyms: [match_synonym],
                     suggestion_synonyms: [suggestion_synonym],
                   },
                 }))
      stub_const("Degrees::DfEReference::COMMON_TYPES", [degree_type])
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
            "data-synonyms" => "#{match_synonym}|#{suggestion_synonym}|#{degree_abbreviation}",
          },
        ],
      ])
    end
  end

  describe "#institutions_options" do
    let(:institution) { "University College London" }
    let(:suggestion_synonym) { "London College University" }
    let(:match_synonym) { "UCL" }

    before do
      stub_const("Degrees::DfEReference::INSTITUTIONS",
                 DfE::ReferenceData::HardcodedReferenceList.new({
                   SecureRandom.uuid => {
                     name: institution,
                     suggestion_synonyms: [suggestion_synonym],
                     match_synonyms: [match_synonym],
                   },
                 }))
    end

    it "iterates over array and prints out correct institutions options" do
      expect(institutions_options).to match([
        [nil, nil, nil],
        [institution, institution, { "data-synonyms" => "#{match_synonym}|#{suggestion_synonym}" }],
      ])
    end
  end

  describe "#subjects_options" do
    let(:degree_subject) { "Mathematics" }
    let(:suggestion_synonym) { "Stats" }
    let(:match_synonym) { "Maths" }

    before do
      stub_const("Degrees::DfEReference::SUBJECTS",
                 DfE::ReferenceData::HardcodedReferenceList.new({
                   SecureRandom.uuid => {
                     name: degree_subject,
                     match_synonyms: [match_synonym],
                     suggestion_synonyms: [suggestion_synonym],
                   },
                 }))
    end

    it "iterates over array and prints out correct subjects values" do
      expect(subjects_options).to match([
        [nil, nil, nil],
        [degree_subject, degree_subject, { "data-synonyms" => "#{match_synonym}|#{suggestion_synonym}" }],
      ])
    end
  end

  describe "#countries_options" do
    before do
      stub_const("Dttp::CodeSets::Countries::MAPPING", { "country" => { country_code: "C" } })
    end

    it "iterates over array and prints out correct countries values" do
      expect(countries_options.size).to be 2
      expect(countries_options.first.value).to be_nil
      expect(countries_options.second.value).to eq "country"
      expect(countries_options.second.text).to eq "Country"
    end
  end
end
