# frozen_string_literal: true

require "rails_helper"

feature "the level 5 declaration comes before course details" do
  background { given_i_am_authenticated }

  scenario "an EYTDA trainee is asked to complete the level 5 declaration first" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, level_five_qualification: nil)

    when_i_visit_the_review_draft_page
    and_i_click_course_details
    then_i_see_the_review_draft_page_with_the_error

    when_i_visit("/trainees/#{trainee.slug}/course-details/edit")
    then_i_see_the_review_draft_page_with_the_error

    when_i_visit("/trainees/#{trainee.slug}/course-details/confirm")
    then_i_see_the_review_draft_page_with_the_error

    when_i_click_the_error_link
    then_i_see_the_level_five_question

    when_i_complete_the_level_five_declaration
    and_i_click_course_details
    then_i_see_the_course_details_page
  end

  scenario "other routes open course details as before" do
    given_a_trainee_exists(:provider_led_postgrad)

    when_i_visit_the_review_draft_page
    and_i_click_course_details
    expect(page).not_to have_css(".govuk-error-summary")
  end

private

  def when_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def when_i_visit(path)
    visit(path)
  end

  def and_i_click_course_details
    within(".app-task-list__item.course-details") { click_on("Course details") }
  end

  def then_i_see_the_review_draft_page_with_the_error
    expect(review_draft_page).to be_displayed(id: trainee.slug)
    expect(page).to have_title(/\A\s*Error: /)
    within(".govuk-error-summary") do
      expect(page).to have_link("Course details for this route require the level 5 declaration to be completed first",
                                href: "/trainees/#{trainee.slug}/level-five-declaration/edit")
    end
    within(".level-five-declaration-details") do
      expect(page).to have_css(".govuk-error-message", text: "Complete the level 5 declaration before adding course details")
    end
  end

  def when_i_click_the_error_link
    click_on("Course details for this route require the level 5 declaration to be completed first")
  end

  def then_i_see_the_level_five_question
    expect(page).to have_css("legend", text: "Does the trainee hold a level 5 qualification?")
  end

  def when_i_complete_the_level_five_declaration
    choose("Yes")
    click_on("Continue")
    check("I have completed this section")
    click_on("Continue")
  end

  def then_i_see_the_course_details_page
    # The edit page, or its confirm page when some course details are already filled in.
    expect(page).to have_current_path(%r{/trainees/#{trainee.slug}/course-details/(edit|confirm)})
    expect(page).not_to have_css(".govuk-error-summary")
  end
end
