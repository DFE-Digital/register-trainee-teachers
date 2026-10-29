# frozen_string_literal: true

require "rails_helper"

feature "Funding management — add funding wizard", feature_funding_management: true, feature_funding_management_edit: true do
  let(:user) { create(:user, :system_admin) }
  # rails_helper seeds previous/current/next cycles for feature specs. Funding is
  # added to a future (draft) year; the live current year is locked (see the
  # "gone live" scenarios below).
  let(:current_cycle) { AcademicCycle.current }
  let(:academic_cycle) { AcademicCycle.next }

  before do
    given_i_am_authenticated(user:)
    create(:allocation_subject, name: "Chemistry")
  end

  scenario "a system admin walks the wizard and adds a single-amount funding band" do
    visit "/system-admin/funding-management/requirements"
    expect(page).to have_css("h1")
    expect(page).not_to have_link("Add funding") # adding is only through Drafts

    visit "/system-admin/funding-management/drafts"
    click_on "Add funding"

    select academic_cycle.label, from: "Which academic year is this funding for?"
    click_on "Continue"

    choose "Bursary"
    click_on "Continue"

    choose "Postgraduate bursary" # funding method
    click_on "Continue"

    check "Provider led postgraduate" # training routes
    click_on "Continue"

    choose "None of these" # Financial Incentive criteria
    click_on "Continue"

    choose "Primary" # education phase
    click_on "Continue"
    # QTS is not asked (award type is derived from the routes); exception is skipped (2027/28+)

    check "Chemistry"
    click_on "Continue"

    fill_in "How much is this funding?", with: "29000"
    click_on "Continue"

    # Check your answers
    expect(page).to have_text("Check your answers")
    expect(page).to have_text("Postgraduate bursary")
    expect(page).to have_text("Provider led postgraduate")
    expect(page).to have_text("£29,000")

    expect {
      click_on "Add funding"
    }.to change(FundingMethod, :count).by(1)

    expect(page).to have_text("Funding added")
    funding_method = FundingMethod.last
    expect(funding_method).to have_attributes(
      training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
      funding_type: "bursary",
      amount: 29_000,
      degree_relevance: nil,
      funding_method: Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY, # "Postgraduate bursary"
    )
    expect(funding_method.reference_number).to be_present
    expect(funding_method.reference).to match(/\AIFR\d{2}\d{3}\z/)
    expect(funding_method.allocation_subjects.pluck(:name)).to contain_exactly("Chemistry")

    # Back on the draft year: it has a record, so more funding can be added here
    expect(page).to have_current_path(%r{requirements\?academic_year=#{academic_cycle.start_year}})
    expect(page).to have_link("Add funding")
  end

  scenario "a system admin adds an Early years tiered bursary with an amount for each tier" do
    create(:allocation_subject, name: "Early years ITT")
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic year (seeded)
    choose "Bursary"
    click_on "Continue"

    expect(page).not_to have_field("Tier 1")
    choose "Early years tiered bursary"
    click_on "Continue"

    # Training routes, Financial Incentive criteria and education phase are skipped:
    # the route is set to Early years postgraduate, an early years route
    expect(page).to have_css("h1", text: "Early years tiered bursary amounts")
    fill_in "Tier 1 amount", with: "5000"
    fill_in "Tier 2 amount", with: "4000"
    fill_in "Tier 3 amount", with: "2000"
    click_on "Continue"

    # Subjects is skipped: early years routes only fund Early years ITT
    expect(page).to have_css("h1", text: "Check your answers")
    expect(page).to have_text("Set by the early years training route")
    expect(page).to have_text("Early years tiered bursary")
    expect(page).to have_text("Early years postgraduate")
    expect(page).to have_text("Set by the funding method")
    expect(page).not_to have_text("Financial Incentive criteria")
    expect(page).to have_text("Tier 1 amount")
    expect(page).to have_text("£4,000")

    expect {
      click_on "Add funding"
    }.to change(FundingMethod, :count).by(3)

    expect(page).to have_text("3 funding records created")
    rows = FundingMethod.order(:reference_number).last(3)
    expect(rows.map { |row| [row.training_route, row.funding_method, row.amount] }).to eq([
      [TRAINING_ROUTE_ENUMS[:early_years_postgrad], Hesa::CodeSets::BursaryLevels::TIER_ONE, 5_000],
      [TRAINING_ROUTE_ENUMS[:early_years_postgrad], Hesa::CodeSets::BursaryLevels::TIER_TWO, 4_000],
      [TRAINING_ROUTE_ENUMS[:early_years_postgrad], Hesa::CodeSets::BursaryLevels::TIER_THREE, 2_000],
    ])
    expect(rows.flat_map { |row| row.allocation_subjects.pluck(:name) }.uniq).to eq(["Early years ITT"])
    expect(page).to have_text("Early years tiered bursary: Tier 2")
  end

  scenario "each missing tier amount gets its own error" do
    create(:allocation_subject, name: "Early years ITT")
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic year (seeded)
    choose "Bursary"
    click_on "Continue"
    choose "Early years tiered bursary"
    click_on "Continue"

    fill_in "Tier 1 amount", with: "5000"
    fill_in "Tier 3 amount", with: "2000"
    click_on "Continue"

    expect(page).to have_css(".govuk-error-summary", text: "Enter the Tier 2 amount")
    expect(page).not_to have_text("Enter the Tier 1 amount")
  end

  scenario "switching away from the tiered bursary asks the skipped questions again" do
    create(:allocation_subject, name: "Early years ITT")
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue"
    choose "Bursary"
    click_on "Continue"
    choose "Early years tiered bursary"
    click_on "Continue"
    fill_in "Tier 1 amount", with: "5000"
    fill_in "Tier 2 amount", with: "4000"
    fill_in "Tier 3 amount", with: "2000"
    click_on "Continue"

    click_link "Change bursary type"
    choose "Postgraduate bursary"
    click_on "Save and continue"

    expect(page).to have_text("Which training routes does this funding apply to?")
  end

  def and_i_add_an_early_years_postgraduate_grant
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"
    click_on "Continue" # academic year (seeded)
    choose "Grant"
    click_on "Continue"
    check "Early years postgraduate" # Financial Incentive criteria and education phase are then skipped
    click_on "Continue"
    fill_in "How much is this funding?", with: "9535"
    click_on "Continue"
  end

  def and_i_start_an_early_years_teacher_degree_apprenticeship_grant
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"
    click_on "Continue" # academic year (seeded)
    choose "Grant"
    click_on "Continue"
  end

  def year_label(year) = Funding::AmountMatrix.year_label(year, academic_cycle.start_year)

  scenario "a system admin adds Early years teacher degree apprenticeship funding for each training year" do
    create(:allocation_subject, name: "Early years ITT")
    and_i_start_an_early_years_teacher_degree_apprenticeship_grant

    check "Early years teacher degree apprenticeship (EYTDA)"
    click_on "Continue"

    expect(page).to have_css("h1", text: "Early years teacher degree apprenticeship amounts")
    fill_in year_label(1), with: "6000"
    fill_in year_label(2), with: "6500"
    fill_in year_label(3), with: "7000"
    expect(page).not_to have_field(year_label(4))
    click_on "Continue"

    # Subjects is skipped: EYTDA is an early years route
    expect(page).to have_css("h1", text: "Check your answers")
    expect(page).to have_text(year_label(3))
    expect(page).to have_text("£7,000")
    expect(page).to have_text("3 funding records")

    expect {
      click_on "Add funding"
    }.to change(FundingMethod, :count).by(3)

    rows = FundingMethod.where(training_route: TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship]).order(:training_year)
    expect(rows.map { |row| [row.training_year, row.amount, row.academic_cycle] }).to eq([
      [1, 6_000, academic_cycle], [2, 6_500, academic_cycle], [3, 7_000, academic_cycle]
    ])
    expect(rows.flat_map { |row| row.allocation_subjects.pluck(:name) }.uniq).to eq(["Early years ITT"])

    expect(page).to have_css("th", text: "Training year")
    expect(page).to have_text(year_label(2))
  end

  scenario "each missing training year amount gets its own error" do
    create(:allocation_subject, name: "Early years ITT")
    and_i_start_an_early_years_teacher_degree_apprenticeship_grant
    check "Early years teacher degree apprenticeship (EYTDA)"
    click_on "Continue"

    fill_in year_label(1), with: "6000"
    fill_in year_label(2), with: "6500"
    click_on "Continue"

    expect(page).to have_css(".govuk-error-summary", text: "Enter the Year 3 amount")
  end

  scenario "Early years teacher degree apprenticeship funding is added on its own" do
    and_i_start_an_early_years_teacher_degree_apprenticeship_grant
    check "Early years teacher degree apprenticeship (EYTDA)"
    check "Early years salaried"
    click_on "Continue"

    expect(page).to have_css(".govuk-error-summary", text: "Add Early years teacher degree apprenticeship funding on its own")
  end

  scenario "an early years route skips the subjects step and sets Early years ITT" do
    create(:allocation_subject, name: "Early years ITT")
    and_i_add_an_early_years_postgraduate_grant

    expect(page).to have_css("h1", text: "Check your answers")
    expect(page).to have_text("Early years ITT")
    expect(page).to have_text("Set by the early years training route")
    expect(page).not_to have_link("Change eligible subjects")
    # Financial Incentive criteria and education phase were not asked
    expect(page).not_to have_text("Financial Incentive criteria")
    expect(page).not_to have_link("Change education phase")
    within(".govuk-summary-list__row", text: "Education phase") { expect(page).to have_text("Not applicable") }

    expect {
      click_on "Add funding"
    }.to change(FundingMethod, :count).by(1)
    expect(FundingMethod.last.allocation_subjects.pluck(:name)).to eq(["Early years ITT"])
  end

  scenario "other routes do not offer Early years ITT" do
    create(:allocation_subject, name: "Early years ITT")
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"
    click_on "Continue"
    choose "Bursary"
    click_on "Continue"
    choose "Postgraduate bursary"
    click_on "Continue"
    check "Provider led postgraduate"
    click_on "Continue"
    choose "None of these"
    click_on "Continue"
    choose "Primary"
    click_on "Continue"

    expect(page).to have_field("Chemistry")
    expect(page).not_to have_field("Early years ITT")
  end

  scenario "changing from an early years route asks for subjects again" do
    create(:allocation_subject, name: "Early years ITT")
    and_i_add_an_early_years_postgraduate_grant

    click_link "Change training routes"
    uncheck "Early years postgraduate"
    check "Postgraduate teaching apprenticeship"
    click_on "Save and continue"

    # No longer early years: the skipped questions are asked
    expect(page).to have_text("Which Financial Incentive criteria apply to this funding?")
    choose "None of these"
    click_on "Continue"
    choose "Secondary"
    click_on "Continue"
    expect(page).to have_text("Which subjects is this funding available for?")
    expect(page).not_to have_field("Early years ITT")
    check "Chemistry"
    click_on "Continue"
    expect(page).to have_css("h1", text: "How much is this funding?")
  end

  scenario "blocks a duplicate combination at check your answers, regardless of amount" do
    existing = create(:funding_method,
                      training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
                      funding_type: :bursary,
                      funding_method: Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY,
                      amount: 12_345, academic_cycle: academic_cycle)
    existing.allocation_subjects << AllocationSubject.find_by(name: "Chemistry")

    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"
    click_on "Continue" # academic year (seeded)
    choose "Bursary"
    click_on "Continue"
    choose "Postgraduate bursary" # funding method
    click_on "Continue"
    check "Provider led postgraduate"
    click_on "Continue"
    choose "None of these" # Financial Incentive criteria
    click_on "Continue"
    choose "Primary"
    click_on "Continue"
    check "Chemistry"
    click_on "Continue"
    fill_in "How much is this funding?", with: "29000" # different amount
    click_on "Continue"

    expect(page).to have_text("Check your answers")
    expect {
      click_on "Add funding"
    }.not_to change(FundingMethod, :count)
    expect(page).to have_text("Funding already exists")
  end

  scenario "the Degree relevancy criterion creates two rows per route (relevant / unrelated)" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic_year pre-seeded
    choose "Bursary"
    click_on "Continue"
    choose "Postgraduate bursary" # funding method
    click_on "Continue"
    check "Provider led postgraduate"
    click_on "Continue"
    choose "Degree relevancy" # Financial Incentive criteria
    click_on "Continue"
    choose "Primary"
    click_on "Continue"

    check "Chemistry"
    click_on "Continue"

    fill_in "Amount for a relevant degree (£)", with: "29000"
    choose "Yes" # there is a bursary for an unrelated degree
    fill_in "Amount for an unrelated degree (£)", with: "25000"
    click_on "Continue"

    expect {
      click_on "Add funding"
    }.to change(FundingMethod, :count).by(2)

    amounts = FundingMethod.where(training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
      .pluck(:degree_relevance, :amount)
    expect(amounts).to contain_exactly(["relevant", 29_000], ["unrelated", 25_000])
  end

  scenario "a bursary asks for the bursary type" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic_year pre-seeded
    expect(page).not_to have_checked_field("Bursary") # nothing pre-selected
    choose "Bursary"
    click_on "Continue"

    expect(page).to have_css("h1", text: "Select bursary type")
    expect(page).not_to have_text("HESA funding method")
    click_on "Continue"
    expect(page).to have_text("Select a bursary type")

    choose "Postgraduate bursary"
    click_on "Continue"
    expect(page).to have_text("Which training routes does this funding apply to?")
  end

  { "Grant" => "E", "Scholarship" => "4" }.each do |funding_type, code|
    scenario "a #{funding_type.downcase} skips the funding method question and sets #{code}" do
      visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

      click_on "Continue" # academic_year pre-seeded
      choose funding_type
      click_on "Continue"

      expect(page).to have_text("Which training routes does this funding apply to?")
      route = funding_type == "Grant" ? "Postgraduate teaching apprenticeship" : "Provider led postgraduate"
      check route
      click_on "Continue"
      choose "None of these"
      click_on "Continue"
      choose "Secondary"
      click_on "Continue"
      check "Chemistry"
      click_on "Continue"
      fill_in "How much is this funding?", with: "5000"
      click_on "Continue"

      expect(page).to have_text("Check your answers")
      expect(page).not_to have_text("Bursary type")
      expect {
        click_on "Add funding"
      }.to change(FundingMethod.where(funding_method: code), :count).by(1)
    end
  end

  scenario "changing a grant to a bursary from Check your answers asks the bursary type" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic_year pre-seeded
    choose "Grant"
    click_on "Continue"
    check "Postgraduate teaching apprenticeship"
    click_on "Continue"
    choose "None of these"
    click_on "Continue"
    choose "Secondary"
    click_on "Continue"
    check "Chemistry"
    click_on "Continue"
    fill_in "How much is this funding?", with: "5000"
    click_on "Continue"

    click_link "Change funding type"
    choose "Bursary"
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Select bursary type")
  end

  scenario "School direct salaried can be given a grant" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic_year pre-seeded
    choose "Grant"
    click_on "Continue"

    expect(page).to have_field("School direct salaried")
    check "School direct salaried"
    click_on "Continue"
    expect(page).not_to have_field("Neither")
    choose "None of these"
    click_on "Continue"
    expect(page).not_to have_field("Not applicable")
    expect(page).to have_field("Both")
    choose "Secondary"
    click_on "Continue"
    check "Chemistry"
    click_on "Continue"
    fill_in "How much is this funding?", with: "29000"
    click_on "Continue"

    expect {
      click_on "Add funding"
    }.to change(FundingMethod.where(training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried]), :count).by(1)
  end

  scenario "Change from Check your answers shows the answers already given" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic_year pre-seeded
    choose "Bursary"
    click_on "Continue"
    choose "Postgraduate bursary"
    click_on "Continue"
    check "Provider led postgraduate"
    click_on "Continue"
    choose "None of these"
    click_on "Continue"
    choose "Primary"
    click_on "Continue"
    check "Chemistry"
    click_on "Continue"
    fill_in "How much is this funding?", with: "29000"
    click_on "Continue"

    click_link "Change eligible subjects"
    expect(page).to have_checked_field("Chemistry")

    click_on "Save and continue"
    expect(page).to have_text("Check your answers")

    click_link "Change training routes"
    expect(page).to have_checked_field("Provider led postgraduate")
  end

  scenario "the Degree relevancy criterion can mark the unrelated degree bursary as not available" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic_year pre-seeded
    choose "Bursary"
    click_on "Continue"
    choose "Postgraduate bursary" # funding method
    click_on "Continue"
    check "Provider led postgraduate"
    click_on "Continue"
    choose "Degree relevancy" # Financial Incentive criteria
    click_on "Continue"
    choose "Primary"
    click_on "Continue"
    check "Chemistry"
    click_on "Continue"

    expect(page).to have_text("Is there a bursary for trainees with an unrelated degree?")
    fill_in "Amount for a relevant degree (£)", with: "29000"
    click_on "Continue"
    expect(page).to have_text("Select whether there is a bursary for trainees with an unrelated degree")

    choose "No, bursary not available"
    click_on "Continue"

    expect(page).to have_text("Unrelated degree: Bursary not available")
    expect(page).to have_text("The unrelated degree records are marked Bursary not available")
    expect {
      click_on "Add funding"
    }.to change(FundingMethod, :count).by(2)

    records = FundingMethod.where(training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
      .pluck(:degree_relevance, :availability, :amount)
    expect(records).to contain_exactly(%w[relevant available] + [29_000], %w[unrelated not_available] + [nil])

    visit "/system-admin/funding-management/requirements?academic_year=#{academic_cycle.start_year}"
    expect(page).to have_text("Bursary not available")
  end

  scenario "the Disadvantaged/special school criterion creates two rows per route" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic_year pre-seeded
    choose "Grant"
    click_on "Continue"
    check "Postgraduate teaching apprenticeship"
    click_on "Continue"
    choose "Disadvantaged or special school" # Financial Incentive criteria
    click_on "Continue"
    choose "Secondary" # education phase
    click_on "Continue"

    check "Chemistry"
    click_on "Continue"

    fill_in "Disadvantaged school/special school", with: "12000"
    fill_in "Non Disadvantaged school", with: "10000"
    click_on "Continue"

    expect(page).to have_text("Disadvantaged school/special school: £12,000")
    expect(page).to have_text("Non Disadvantaged school: £10,000")

    expect {
      click_on "Add funding"
    }.to change(FundingMethod, :count).by(2)

    amounts = FundingMethod.where(training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship])
      .pluck(:school_disadvantage, :amount)
    expect(amounts).to contain_exactly(["disadvantaged", 12_000], ["non_disadvantaged", 10_000])
  end

  scenario "only shows training routes that match the earlier answers" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic year (seeded)
    choose "Grant"
    click_on "Continue"

    # Grant funding → only grant routes are shown; non-grant routes are hidden entirely
    expect(page).to have_field("Postgraduate teaching apprenticeship")
    expect(page).not_to have_field("Provider led postgraduate")
    expect(page).not_to have_text("Not available for grant funding")
  end

  scenario "shows an error when a required step is not answered" do
    visit "/system-admin/funding-management/add?academic_year=#{academic_cycle.start_year}"

    click_on "Continue" # academic year (seeded)
    choose "Bursary"
    click_on "Continue"
    choose "Postgraduate bursary" # funding method
    click_on "Continue"
    click_on "Continue" # training routes — nothing checked

    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_text("Select at least one training route")
  end

  scenario "does not offer Add funding once the year has gone live" do
    visit "/system-admin/funding-management/requirements?academic_year=#{current_cycle.start_year}"
    expect(page).to have_css("h1")

    expect(page).not_to have_link("Add funding", exact: true)
    if current_cycle.eytda_only_funding_year?
      # 2026 to 2027: live, but EYTDA funding can still be added.
      expect(page).to have_link("Add EYTDA funding")
      expect(page).to have_text("its funding is locked, except for Early years teacher degree apprenticeship (EYTDA) funding")
    else
      expect(page).to have_text("This academic year is live, so its funding is locked. Any amendment will need a Register developer.")
    end
  end

  context "in 2026 to 2027, live but open to EYTDA funding" do
    around { |example| Timecop.travel(Date.new(2026, 10, 12)) { example.run } }

    let!(:eytda_year) { AcademicCycle.for_year(2026) || create(:academic_cycle, start_date: Date.new(2026, 8, 1), end_date: Date.new(2027, 7, 31)) }

    scenario "a system admin adds EYTDA funding for 2026 to 2027, then signs it off from Drafts" do
      create(:allocation_subject, name: "Early years ITT")
      visit "/system-admin/funding-management/add"
      select "2026 to 2027 (EYTDA only)", from: "Which academic year is this funding for?"
      click_on "Continue"

      expect(page).to have_text("For 2026 to 2027, only Early years teacher degree apprenticeship (EYTDA) grants can be added.")
      expect(page).to have_field("Grant")
      expect(page).not_to have_field("Bursary")
      choose "Grant"
      click_on "Continue"

      expect(page).to have_field("Early years teacher degree apprenticeship (EYTDA)")
      expect(page).not_to have_field("School direct salaried")
      check "Early years teacher degree apprenticeship (EYTDA)"
      click_on "Continue"

      fill_in "Year 1 (26/27)", with: "6000"
      fill_in "Year 2 (27/28)", with: "6500"
      fill_in "Year 3 (28/29)", with: "7000"
      click_on "Continue"

      expect { click_on "Add funding" }.to change { eytda_year.funding_methods.count }.by(3)

      visit "/system-admin/funding-management/drafts"
      expect(page).to have_css(".govuk-tag", text: "Draft (EYTDA only)")
      click_on "Sign off"
      expect(page).to have_text("3")
    end
  end

  scenario "does not list a live year on the wizard's academic-year step" do
    visit "/system-admin/funding-management/add"

    field = find_field("Which academic year is this funding for?")
    expect(field).to have_css("option", exact_text: academic_cycle.label)
    expect(field).not_to have_css("option", exact_text: current_cycle.label)
  end
end
