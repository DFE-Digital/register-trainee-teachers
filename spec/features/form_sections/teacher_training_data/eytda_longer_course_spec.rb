# frozen_string_literal: true

require "rails_helper"

feature "confirming an EYTDA course that's longer than usual" do
  background { given_i_am_authenticated }

  scenario "any end date is allowed, and a longer course is confirmed" do
    given_an_eytda_trainee_with_a_level_five_qualification

    when_i_enter_the_course_dates("01/09/2027", "01/09/2030")
    then_i_see_the_course_length_warning_without_an_error

    when_i_continue_without_confirming
    then_i_am_asked_to_confirm_the_longer_course

    when_i_confirm_the_longer_course
    then_the_confirm_page_shows_the_course_length
    and_the_declaration_is_saved
  end

  scenario "an end date past the latest year on other routes is allowed once confirmed" do
    given_an_eytda_trainee_with_a_level_five_qualification

    when_i_enter_the_course_dates("01/09/2027", "01/09/2037")
    then_i_see_the_course_length_warning_without_an_error("10 years")

    when_i_confirm_the_longer_course
    then_the_confirm_page_shows_the_course_length("10 years")
  end

  scenario "the warning isn't shown before the course is longer than usual" do
    given_an_eytda_trainee_with_a_level_five_qualification

    course_details_page.load(id: trainee.slug)
    then_the_course_length_section_is_hidden
  end

  scenario "an end date within the usual length needs no declaration" do
    given_an_eytda_trainee_with_a_level_five_qualification

    when_i_enter_the_course_dates("01/09/2027", "01/07/2029")
    then_i_see_the_confirm_page_without_a_course_length
  end

private

  def given_an_eytda_trainee_with_a_level_five_qualification
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, level_five_qualification: true,
                                                                       study_mode: "full_time",
                                                                       progress: Progress.new(level_five_declaration: true))
  end

  def when_i_enter_the_course_dates(start_date, end_date)
    course_details_page.load(id: trainee.slug)
    choose("Full time")
    course_details_page.set_date_fields("itt_start_date", start_date)
    course_details_page.set_date_fields("itt_end_date", end_date)
    click_on("Continue")
  end

  def then_i_see_the_course_length_warning_without_an_error(length = "3 years")
    expect(page).to have_css(".govuk-warning-text", text: "This course is #{length}. " \
                                                          "Courses for trainees with a level 5 qualification are usually 2 years.")
    expect(page).to have_unchecked_field("I confirm the course is longer than 2 years")
    expect(page).not_to have_css(".govuk-error-summary")
  end

  def when_i_continue_without_confirming
    click_on("Continue")
  end

  def then_i_am_asked_to_confirm_the_longer_course
    expect(page).to have_css(".govuk-error-summary", text: "Confirm the course is longer than 2 years")
    expect(page).to have_css(".govuk-warning-text", text: "This course is 3 years.")
  end

  def when_i_confirm_the_longer_course
    check("I confirm the course is longer than 2 years")
    click_on("Continue")
  end

  def then_the_confirm_page_shows_the_course_length(length = "3 years")
    expect(page).to have_text("Course length")
    expect(page).to have_text(length)
    expect(page).to have_text("Confirmed as longer than the usual 2 years for a trainee with a level 5 qualification")
  end

  def and_the_declaration_is_saved
    expect(trainee.reload).to have_attributes(itt_end_date: Date.new(2030, 9, 1), extended_course_confirmed: true)
  end

  def then_the_course_length_section_is_hidden
    expect(page).to have_css("[data-module='app-course-length'][hidden]", visible: :hidden)
  end

  def then_i_see_the_confirm_page_without_a_course_length
    expect(page).to have_text("Confirm trainee’s course details").or have_text("Confirm trainee's course details")
    expect(page).not_to have_text("Course length")
  end
end
