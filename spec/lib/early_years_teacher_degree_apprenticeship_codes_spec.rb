# frozen_string_literal: true

require "rails_helper"

describe "Early years teacher degree apprenticeship codes" do
  let(:route) { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] }

  it "keeps route code 15" do
    expect(TRAINING_ROUTES[route]).to eq(15)
  end

  it "uses HESA code 23 in the reference data" do
    expect(ReferenceData::TRAINING_ROUTES.find_by_hesa_code("23")&.name).to eq(route)
    expect(ReferenceData::TRAINING_ROUTES.hesa_code_for(route)).to eq("23")
  end

  it "is only valid from the 2027 to 2028 academic year" do
    value = ReferenceData::TRAINING_ROUTES.find_by_hesa_code("23")

    expect(value.valid_in?(year: 2026)).to be(false)
    expect(value.valid_in?(year: 2027)).to be(true)
  end

  it "maps HESA code 23 for the HESA import" do
    expect(Hesa::CodeSets::TrainingRoutes::MAPPING["23"]).to eq(route)
  end

  it "maps the suggested funding spreadsheet label" do
    expect(Funding::ProviderTraineeSummariesImporter::SummaryRowMapper::TRAINING_ROUTES["EYITT Teacher Degree Apprenticeship"]).to eq(route)
  end
end
