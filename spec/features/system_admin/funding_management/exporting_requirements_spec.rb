# frozen_string_literal: true

require "rails_helper"
require "csv"

feature "Funding management — export funding requirements as a CSV", feature_funding_management: true do
  let(:user) { create(:user, :system_admin) }
  # rails_helper seeds previous/current/next cycles for feature specs.
  let(:next_cycle) { AcademicCycle.next }
  let(:chemistry) { create(:allocation_subject, name: "Chemistry") }
  let(:physics) { create(:allocation_subject, name: "Physics") }

  before do
    given_i_am_authenticated(user:)
    # More entries than fit on one page of the list.
    stub_const("SystemAdmin::FundingMethodsController::ENTRIES_PER_PAGE", 2)
    create_list(:funding_method, 2, academic_cycle: next_cycle, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
                                    funding_type: :bursary, amount: 20_000)
      .each { |method| method.allocation_subjects << chemistry }
    create(:funding_method, academic_cycle: next_cycle, training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
                            funding_type: :grant, amount: 26_000, degree_relevance: :relevant)
      .tap { |method| method.allocation_subjects << physics }
  end

  scenario "downloads every draft entry, not only the current page" do
    visit "/system-admin/funding-management/requirements?academic_year=#{next_cycle.start_year}&page=2"
    click_on "Download draft funding requirements (CSV)"

    expect(page.response_headers["Content-Type"]).to include("text/csv")
    expect(page.response_headers["Content-Disposition"]).to include("draft-funding-requirements-#{next_cycle.label.parameterize}")

    rows = CSV.parse(page.body, headers: true)
    expect(rows.headers).to eq(Funding::RequirementsExport::HEADERS)
    expect(rows.size).to eq(3)

    grant = rows.find { |row| row["Subject"] == "Physics" }
    expect(grant["Academic year"]).to eq(next_cycle.label)
    expect(grant["Status"]).to eq("Draft")
    expect(grant["Funding type"]).to eq("Grant")
    expect(grant["Training route"]).to eq("School direct salaried")
    expect(grant["Degree relevance"]).to eq("Relevant")
    expect(grant["Amount"]).to eq("26000")
    expect(grant["Available"]).to eq("Yes")
    expect(grant["Source"]).to eq("This year")
  end

  scenario "keeps the filters chosen on the page" do
    visit "/system-admin/funding-management/requirements?academic_year=#{next_cycle.start_year}&funding_type=grant"
    click_on "Download draft funding requirements (CSV)"

    rows = CSV.parse(page.body, headers: true)
    expect(rows.map { |row| row["Subject"] }).to eq(%w[Physics])
  end
end
