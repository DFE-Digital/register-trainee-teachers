# frozen_string_literal: true

require "rails_helper"

feature "confirming the course details and adding the funding again after the level 5 declaration changes" do
  # The years' funding is signed off, as it will be by the time trainees start.
  before { AcademicCycle.find_each { |cycle| cycle.update!(published: true) } }

  background { given_i_am_authenticated }

  scenario "course details go back to in progress and the funding is removed, to be added again" do
    given_an_eytda_trainee_with_course_details_and_funding_complete

    when_i_visit_the_level_five_declaration_question
    then_i_see_the_warning

    when_i_answer("No")
    and_i_visit_the_review_draft_page
    then_i_see_the_banner("Add the funding and check the course details again",
                          "The level 5 declaration changed, so check the course details are still right. The funding was removed, so add it again.")
    and_the_funding_answers_are_cleared
    and_the_task_is(".course-details", "In progress", hint: "Level 5 declaration changed. Check and confirm the course details")
    and_the_task_is(".funding", "Cannot start yet")
    and_there_is_no_funding_link_yet

    when_i_check_the_record
    then_i_see_the_message("Course details needs to be confirmed again because the level 5 declaration changed")

    when_i_visit_the_review_draft_page
    and_i_click("Check the course details")
    then_i_see_the_confirm_banner("The level 5 declaration changed after the course details were added")
    and_i_confirm_the_section
    then_the_task_is(".course-details", "Completed")
    and_i_see_the_banner("Add the funding again", "The level 5 declaration changed, so the funding was removed.")
    and_the_task_is(".funding", "Incomplete", hint: "Level 5 declaration changed. Add the funding again")
    expect(page).to have_link("Add the funding")
  end

  scenario "saving the same answer again changes nothing" do
    given_an_eytda_trainee_with_course_details_and_funding_complete

    when_i_visit_the_level_five_declaration_question
    and_i_answer("Yes")
    and_i_visit_the_review_draft_page
    then_the_task_is(".course-details", "Completed")
    and_the_task_is(".funding", "Completed")
    and_i_see_no_banner
  end

  scenario "no warning before course details or funding are complete" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship)

    when_i_visit_the_level_five_declaration_question
    expect(page).not_to have_css(".govuk-warning-text")
  end

private

  def given_an_eytda_trainee_with_course_details_and_funding_complete
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, study_mode: "full_time",
                                                                       level_five_qualification: true,
                                                                       funding_eligibility: :eligible, applying_for_grant: true,
                                                                       training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative],
                                                                       progress: Progress.new(level_five_declaration: true, course_details: true, funding: true))
    trainee.update!(itt_end_date: trainee.itt_start_date + 2.years)
  end

  def when_i_visit_the_level_five_declaration_question
    visit "/trainees/#{trainee.slug}/level-five-declaration/edit"
  end

  def then_i_see_the_warning
    expect(page).to have_css(".govuk-warning-text", text: "If you change this answer, the course details will need to be checked and confirmed again, and the funding will be removed so you can add it again.")
  end

  def when_i_answer(answer)
    choose(answer)
    click_on("Continue")
  end
  alias_method :and_i_answer, :when_i_answer

  def when_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end
  alias_method :and_i_visit_the_review_draft_page, :when_i_visit_the_review_draft_page

  def when_i_check_the_record
    visit "/trainees/#{trainee.slug}/check-details"
    click_on("Register trainee and request TRN")
  end

  def then_i_see_the_message(text)
    expect(page).to have_text(text)
  end

  def and_there_is_no_funding_link_yet
    expect(page).to have_link("Check the course details")
    expect(page).not_to have_link("Add the funding")
  end

  def and_the_funding_answers_are_cleared
    expect(trainee.reload).to have_attributes(funding_eligibility: nil, training_initiative: nil, applying_for_grant: nil)
  end

  def then_i_see_the_banner(heading, text)
    within(".govuk-notification-banner", text: heading) do
      expect(page).to have_css(".govuk-notification-banner__heading", text: heading)
      expect(page).to have_text(text)
    end
  end
  alias_method :and_i_see_the_banner, :then_i_see_the_banner

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
  alias_method :and_i_click, :when_i_click

  def then_i_see_the_confirm_banner(heading)
    expect(page).to have_css(".govuk-notification-banner__heading", text: heading)
    expect(page).to have_unchecked_field("I have completed this section")
  end

  def and_i_confirm_the_section
    check("I have completed this section")
    click_on("Continue")
  end
end
