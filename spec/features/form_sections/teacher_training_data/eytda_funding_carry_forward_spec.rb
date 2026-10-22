# frozen_string_literal: true

require "rails_helper"

feature "EYTDA amounts apply to later start years", feature_funding_draft_amounts_in_journey: true, feature_funding_eligibility_step: true do
  def cycle_for(year)
    AcademicCycle.for_year(year) || create(:academic_cycle, start_date: Date.new(year, 8, 1), end_date: Date.new(year + 1, 7, 31))
  end

  let(:early_years_itt) { create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT) }

  before do
    cycle_for(2026)
    cycle_for(2027)
    create(:subject_specialism, allocation_subject: early_years_itt, name: CourseSubjects::EARLY_YEARS_TEACHING)
  end

  def add_eytda_amounts
    { 1 => 8_236, 2 => 8_236, 3 => 6_177 }.each do |training_year, amount|
      funding_method = create(:funding_method, training_route: FundingManager::EYTDA_ROUTE, funding_type: FUNDING_TYPE_ENUMS[:grant],
                                               academic_cycle: cycle_for(2026), amount: amount, training_year: training_year)
      create(:funding_method_subject, funding_method: funding_method, allocation_subject: early_years_itt)
    end
  end

  def given_a_2027_eytda_trainee
    given_i_am_authenticated
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, progress: Progress.new(course_details: true))
    trainee.update!(itt_start_date: Date.new(2027, 9, 1), itt_end_date: Date.new(2030, 9, 1), course_allocation_subject: early_years_itt,
                    course_subject_one: CourseSubjects::EARLY_YEARS_TEACHING, funding_eligibility: :eligible)
  end

  scenario "a 2027 to 2028 starter gets the grant entered for 2026 to 2027" do
    add_eytda_amounts
    given_a_2027_eytda_trainee

    visit "/trainees/#{trainee.slug}/funding/bursary/edit"
    expect(page).to have_text("Grant for trainees starting in 2027 to 2028")
    expect(page).to have_text("These amounts were set for 2026 to 2027 and apply to trainees starting in later years until new amounts are added.")
    expect(page).to have_text("Year 1 (27/28)")
    expect(page).to have_text("£8,236")
    expect(page).to have_text("These amounts are from the 2026 to 2027 draft")
  end

  scenario "with no EYTDA amounts at all, the funding type page isn't shown" do
    given_a_2027_eytda_trainee

    visit "/trainees/#{trainee.slug}/funding/bursary/edit"
    expect(page).to have_current_path("/trainees/#{trainee.slug}/funding/confirm")
    expect(page).not_to have_text("has a bursary available of")
  end

  scenario "requirements for 2027 to 2028 show the EYTDA amounts carried forward", feature_funding_management: true do
    add_eytda_amounts
    given_i_am_authenticated(user: create(:user, :system_admin))

    visit "/system-admin/funding-management/requirements?academic_year=2027"
    expect(page).to have_css("h2", text: "Carried forward from 2026 to 2027")
    expect(page).to have_text("Early years teacher degree apprenticeship (EYTDA) amounts from 2026 to 2027 apply to this year")
    expect(page).to have_text("Year 1 (27/28)")
  end
end
