# frozen_string_literal: true

require "rails_helper"

feature "checking the funding again after the degree or employing school changes", feature_funding_eligibility_step: true do
  # The years' funding is signed off, as it will be by the time trainees start.
  before { AcademicCycle.find_each { |cycle| cycle.update!(published: true) } }

  background { given_i_am_authenticated }

  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }

  scenario "changing the employing school the funding depends on makes completed funding in progress until it's confirmed again" do
    given_a_trainee_with_completed_funding(:pg_teaching_apprenticeship)
    and_the_grant_depends_on_the_employing_school

    when_i_visit_the_review_draft_page
    then_the_funding_is("Completed")
    and_i_see_no_recheck_banner

    when_i_change_the_employing_school
    and_i_visit_the_review_draft_page
    then_the_funding_is("In progress")
    and_i_see_the_recheck_banner("The employing school changed, so check the funding is still right.")
    and_the_funding_task_has_the_hint("Employing school changed. Check and confirm the funding")

    when_i_click_check_the_funding
    then_i_see_the_confirm_banner("The employing school changed after the funding was added")
    and_i_have_not_completed_the_section

    when_i_confirm_the_funding
    then_the_funding_is("Completed")
    and_i_see_no_recheck_banner
  end

  scenario "changing the employing school leaves funding that doesn't depend on it alone" do
    given_a_trainee_with_completed_funding(:school_direct_salaried)

    when_i_change_the_employing_school
    and_i_visit_the_review_draft_page
    then_the_funding_is("Completed")
    and_i_see_no_recheck_banner
  end

  scenario "completed funding that needs a missing employing school is in progress" do
    given_a_trainee_with_completed_funding(:pg_teaching_apprenticeship)
    and_the_grant_depends_on_the_employing_school
    and_the_trainee_has_no_employing_school

    when_i_visit_the_review_draft_page
    then_the_funding_is("In progress")

    when_i_click_the_funding_section
    then_i_see_the_error("Funding for this route requires the employing school to be completed first")
  end

private

  def given_a_trainee_with_completed_funding(route)
    create(:subject_specialism, allocation_subject: mathematics, name: CourseSubjects::MATHEMATICS)
    given_a_trainee_exists(route, :with_valid_itt_start_date, :with_employing_school, course_subject_one: CourseSubjects::MATHEMATICS,
                                                                                      funding_eligibility: :eligible,
                                                                                      training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative],
                                                                                      applying_for_grant: false,
                                                                                      progress: Progress.new(course_details: true, funding: true))
    trainee.update!(course_allocation_subject: mathematics, start_academic_cycle: cycle)
  end

  def and_the_grant_depends_on_the_employing_school
    %i[disadvantaged non_disadvantaged].each do |designation|
      funding_method = create(:funding_method, training_route: trainee.training_route, funding_type: FUNDING_TYPE_ENUMS[:grant], amount: 20_000,
                                               academic_cycle: cycle, school_disadvantage: designation)
      create(:funding_method_subject, funding_method: funding_method, allocation_subject: mathematics)
    end
  end

  def and_the_trainee_has_no_employing_school
    trainee.update!(employing_school_not_applicable: true)
  end

  def when_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end
  alias_method :and_i_visit_the_review_draft_page, :when_i_visit_the_review_draft_page

  def when_i_change_the_employing_school
    new_school = create(:school, name: "Falconholt 1 High")
    visit("/trainees/#{trainee.slug}/employing-schools?query=Falconholt")
    choose(new_school.name)
    click_on("Continue")
    expect(trainee.reload.employing_school).to eq(new_school)
  end

  def when_i_click_check_the_funding
    click_on("Check the funding")
  end

  def when_i_click_the_funding_section
    review_draft_page.funding_section.link.click
  end

  def when_i_confirm_the_funding
    check("I have completed this section")
    click_on("Continue")
  end

  def then_the_funding_is(status)
    within(".app-task-list__item.funding") do
      expect(page).to have_css(".govuk-tag", text: status)
    end
  end

  def and_i_see_the_recheck_banner(text)
    within(".govuk-notification-banner", text: "Check the funding again") do
      expect(page).to have_text(text)
    end
  end

  def and_i_see_no_recheck_banner
    expect(page).not_to have_text("Check the funding again")
  end

  def and_the_funding_task_has_the_hint(text)
    within(".app-task-list__item.funding") do
      expect(page).to have_css(".govuk-hint", text:)
    end
  end

  def then_i_see_the_confirm_banner(heading)
    expect(page).to have_current_path("/trainees/#{trainee.slug}/funding/confirm")
    expect(page).to have_css(".govuk-notification-banner__heading", text: heading)
  end

  def and_i_have_not_completed_the_section
    expect(page).to have_unchecked_field("I have completed this section")
  end

  def then_i_see_the_error(message)
    expect(review_draft_page).to be_displayed(id: trainee.slug)
    within(".govuk-error-summary") do
      expect(page).to have_link(message)
    end
  end
end
