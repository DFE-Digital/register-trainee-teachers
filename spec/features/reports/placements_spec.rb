# frozen_string_literal: true

require "rails_helper"

feature "placements report download" do
  let(:current_academic_cycle) { AcademicCycle.current }
  let(:school) do
    create(
      :school,
      name: "Bluemeadow Secondary College",
      urn: "594773",
      town: "Spencershire",
      postcode: "Y7D 4NA",
    )
  end

  background do
    allow(DetermineSignOffPeriod).to receive(:call).and_return(:outside_period)
    given_i_am_authenticated
    create_trainee_with_current_academic_year_placement
  end

  scenario "downloads a CSV with current academic year placements" do
    when_i_visit_the_reports_page
    and_i_click_the_placements_report_link
    then_i_receive_a_csv_with_the_expected_filename
    and_the_csv_contains_the_trainee_placement_data
  end

private

  def create_trainee_with_current_academic_year_placement
    trainee = create(
      :trainee,
      :provider_led_postgrad,
      :trn_received,
      :with_secondary_education,
      provider: current_user.organisation,
      trn: "6800243",
      itt_start_date: Date.new(2026, 9, 16),
    )
    create(
      :placement,
      :with_school,
      trainee: trainee,
      school: school,
      created_at: current_academic_cycle.start_date + 1.day,
    )
  end

  def when_i_visit_the_reports_page
    reports_page.load
  end

  def and_i_click_the_placements_report_link
    reports_page.placements_report_link.click
  end

  def then_i_receive_a_csv_with_the_expected_filename
    expect(page.response_headers["Content-Type"]).to eq("text/csv; charset=utf-8")
    expect(page.response_headers["Content-Disposition"]).to include(
      "#{current_academic_cycle.label('-')}-placements-report-",
    )
    expect(page.response_headers["Content-Disposition"]).to include(".csv")
  end

  def and_the_csv_contains_the_trainee_placement_data
    csv = CSV.parse(page.body, headers: true)
    row = csv.first

    expect(csv.headers).to eq(
      [
        "TRN",
        "Trainee ITT start date",
        "Education phase",
        "Placement 1 URN",
        "Placement 1 address",
        "Placement 2 URN",
        "Placement 2 address",
        "Placement 3 URN",
        "Placement 3 address",
        "Placement 4 URN",
        "Placement 4 address",
        "Placement 5 URN",
        "Placement 5 address",
      ],
    )
    expect(row["TRN"]).to eq("6800243")
    expect(row["Trainee ITT start date"]).to eq("16/09/2026")
    expect(row["Education phase"]).to eq("Secondary")
    expect(row["Placement 1 URN"]).to eq("594773")
    expect(row["Placement 1 address"]).to eq(
      "Bluemeadow Secondary College, URN 594773, Spencershire, Y7D 4NA",
    )
  end
end
