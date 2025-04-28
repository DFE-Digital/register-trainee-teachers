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
      stub_const("DfEReference::DegreesQuery::TYPES",
                 DfE::ReferenceData::HardcodedReferenceList.new({
                   SecureRandom.uuid => {
                     name: degree_type,
                     abbreviation: degree_abbreviation,
                     match_synonyms: [match_synonym],
                     suggestion_synonyms: [suggestion_synonym],
                   },
                 }))
      stub_const("DfEReference::DegreesQuery::COMMON_TYPES", [degree_type])
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
      stub_const("DfEReference::DegreesQuery::INSTITUTIONS",
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
      stub_const("DfEReference::DegreesQuery::SUBJECTS",
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
    it "iterates over array and prints out correct countries values" do
      expect(countries_options.first.value).to be_nil
      # Pre and post-DfE::ReferenceData::CountriesAndTerritories update https://github.com/DFE-Digital/dfe-reference-data/pull/139/
      expect(countries_options.second.value).to eq("Abu Dhabi").or eq("Afghanistan")
      expect(countries_options.second.text).to eq("Abu Dhabi").or eq("Afghanistan")
    end
  end
end
