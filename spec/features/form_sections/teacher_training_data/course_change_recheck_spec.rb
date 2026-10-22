# frozen_string_literal: true

require "rails_helper"

feature "adding the funding and checking the employing school again after the course details change", feature_funding_eligibility_step: true do
  # The years' funding is signed off, as it will be by the time trainees start.
  before { AcademicCycle.find_each { |cycle| cycle.update!(published: true) } }

  background { given_i_am_authenticated }

  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }

  scenario "the funding is removed to be added again, and the employing school goes back to in progress" do
    given_a_teaching_apprenticeship_trainee_with_everything_complete

    when_the_course_details_change
    and_i_visit_the_review_draft_page
    then_i_see_the_banner("Add the funding and check the employing school again",
                          "The course details changed, so the funding was removed.")
    and_the_task_is(".school-details", "In progress", hint: "Course details changed. Check and confirm the employing school")
    and_the_task_is(".funding", "Incomplete", hint: "Course details changed. Add the funding again")
    and_the_funding_answers_are_cleared

    when_i_click("Check the employing school")
    then_i_see_the_confirm_banner("The course details changed after the employing school was added")
    and_i_confirm_the_section
    then_the_task_is(".school-details", "Completed")
    and_i_see_the_banner("Add the funding again", "The course details changed, so the funding was removed.")
    expect(page).to have_link("Add the funding")
  end

  scenario "a route change removes the funding and says why" do
    given_a_teaching_apprenticeship_trainee_with_everything_complete

    when_the_route_changes
    and_i_visit_the_review_draft_page
    then_i_see_the_banner("Add the funding and check the employing school again", "The training route changed, so the funding was removed.")
  end

  scenario "entering other details doesn't ask for anything to be checked again" do
    given_a_teaching_apprenticeship_trainee_with_everything_complete

    trainee.update!(first_names: "Changed")
    and_i_visit_the_review_draft_page
    and_i_see_no_banner
    then_the_task_is(".funding", "Completed")
  end

private

  def given_a_teaching_apprenticeship_trainee_with_everything_complete
    create(:subject_specialism, allocation_subject: mathematics, name: CourseSubjects::MATHEMATICS)
    given_a_trainee_exists(:pg_teaching_apprenticeship, :with_valid_itt_start_date, :with_employing_school,
                           course_subject_one: CourseSubjects::MATHEMATICS, study_mode: "full_time",
                           training_partner_not_applicable: true, funding_eligibility: :eligible,
                           training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative], applying_for_grant: false,
                           progress: Progress.new(course_details: true, schools: true, funding: true))
    trainee.update!(course_allocation_subject: mathematics, start_academic_cycle: cycle)
  end

  def when_the_course_details_change
    trainee.update!(study_mode: "part_time")
  end

  def when_the_route_changes
    RouteDataManager.new(trainee:).update_training_route!(TRAINING_ROUTE_ENUMS[:school_direct_salaried])
    trainee.save!
  end

  def and_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def then_i_see_the_banner(heading, text)
    within(".govuk-notification-banner", text: heading) do
      expect(page).to have_css(".govuk-notification-banner__heading", text: heading)
      expect(page).to have_text(text)
    end
  end
  alias_method :and_i_see_the_banner, :then_i_see_the_banner

  def and_the_funding_answers_are_cleared
    expect(trainee.reload).to have_attributes(funding_eligibility: nil, training_initiative: nil, applying_for_grant: nil)
  end

  def and_i_see_no_banner
    expect(page).not_to have_text("again")
  end

  def then_the_task_is(selector, status, hint: nil)
    within(".app-task-list__item#{selector}") do
      expect(page).to have_css(".govuk-tag", text: status)
      expect(page).to have_css(".govuk-hint", text: hint) if hint
    end
  end
  alias_method :and_the_task_is, :then_the_task_is

  def when_i_click(text)
    click_on(text)
  end

  def then_i_see_the_confirm_banner(heading)
    expect(page).to have_css(".govuk-notification-banner__heading", text: heading)
    expect(page).to have_unchecked_field("I have completed this section")
  end

  def and_i_confirm_the_section
    check("I have completed this section")
    click_on("Continue")
  end
end
