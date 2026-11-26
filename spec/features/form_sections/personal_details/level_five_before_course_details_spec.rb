# frozen_string_literal: true

require "rails_helper"

feature "course details before the level 5 declaration" do
  background { given_i_am_authenticated }

  scenario "an EYTDA trainee can enter the course dates before the level 5 declaration" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, level_five_qualification: nil, itt_start_date: nil, itt_end_date: nil)

    when_i_visit_the_review_draft_page
    and_i_click_course_details
    then_i_see_the_course_details_page_for_an_apprenticeship
    and_the_end_date_hint_says_it_is_filled_in_with_the_standard_length

    when_i_enter_the_start_date_only
    then_the_end_date_is_filled_in_with_33_months
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

  def and_i_click_course_details
    within(".app-task-list__item.course-details") { click_on("Course details") }
  end

  def then_i_see_the_course_details_page_for_an_apprenticeship
    expect(page).to have_current_path("/trainees/#{trainee.slug}/course-details/edit")
    expect(page).not_to have_css(".govuk-error-summary")
    expect(page).to have_text("Study mode")
    expect(page).to have_text("Full-time")
    expect(page).not_to have_field("Part time")
    expect(page).to have_css("legend", text: "Course start date")
    expect(page).to have_css("legend", text: "Expected end date")
  end

  def and_the_end_date_hint_says_it_is_filled_in_with_the_standard_length
    expect(page).to have_text("Filled in as 33 months after the course start date, the standard length.")
  end

  def when_i_enter_the_start_date_only
    course_details_page.set_date_fields("itt_start_date", "01/09/2026")
    click_on("Continue")
  end

  def then_the_end_date_is_filled_in_with_33_months
    expect(trainee.reload).to have_attributes(itt_start_date: Date.new(2026, 9, 1), itt_end_date: Date.new(2029, 6, 1), study_mode: "full_time")
  end
end
