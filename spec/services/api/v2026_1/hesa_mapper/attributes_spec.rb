# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::HesaMapper::Attributes do
  def mapped(params)
    described_class.call(params:)
  end

  def diverging(mapping)
    mapping.each_with_object([]) do |(code, expected), out|
      actual = yield(code)
      out << "#{code}: #{actual.inspect} != #{expected.inspect}" if actual != expected
    end
  end

  it "maps ethnicity for every code" do
    divergences = diverging(Hesa::CodeSets::Ethnicities::MAPPING) { |code| mapped(ethnicity: code)[:ethnic_background] }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps sex for every code" do
    divergences = diverging(Hesa::CodeSets::Sexes::MAPPING) { |code| mapped(sex: code)[:sex] }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps training_route for every code" do
    divergences = diverging(Hesa::CodeSets::TrainingRoutes::MAPPING) { |code| mapped(training_route: code)[:training_route] }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps training_initiative for every code" do
    divergences = diverging(Hesa::CodeSets::TrainingInitiatives::MAPPING) { |code| mapped(training_initiative: code)[:training_initiative] }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps iqts_country for every code" do
    divergences = diverging(Hesa::CodeSets::Countries::MAPPING) { |code| mapped(iqts_country: code)[:iqts_country] }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps course subjects for every code" do
    divergences = diverging(Hesa::CodeSets::CourseSubjects::MAPPING) { |code| mapped(course_subject_1: code)[:course_subject_one] }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps study_mode for every code" do
    expected = Hesa::CodeSets::StudyModes::MAPPING.transform_values { |value| TRAINEE_STUDY_MODE_ENUMS.invert[value] }
    divergences = diverging(expected) { |code| mapped(study_mode: code)[:study_mode] }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps nationality for every code" do
    divergences = diverging(RecruitsApi::CodeSets::Nationalities::MAPPING) { |code| mapped(nationality: code)[:nationalisations_attributes]&.first&.dig(:name) }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps fund_code eligibility for every code" do
    expected = {
      Hesa::CodeSets::FundCodes::ELIGIBLE => FUNDING_ELIGIBILITIES[:eligible],
      Hesa::CodeSets::FundCodes::NOT_ELIGIBLE => FUNDING_ELIGIBILITIES[:not_eligible],
    }
    divergences = diverging(expected) { |code| mapped(fund_code: code)[:funding_eligibility] }
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps course age ranges for every code" do
    divergences = diverging(DfE::ReferenceData::AgeRanges::HESA_CODE_SETS) do |code|
      result = mapped(course_age_range: code)
      [result[:course_min_age], result[:course_max_age]]
    end
    expect(divergences).to be_empty, divergences.join("\n")
  end
end
