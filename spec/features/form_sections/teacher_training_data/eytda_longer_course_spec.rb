# frozen_string_literal: true

require "rails_helper"

feature "confirming an EYTDA course that's longer than usual" do
  background { given_i_am_authenticated }

  scenario "any end date is allowed, and a longer course is confirmed" do
    given_an_eytda_trainee_with_a_level_five_qualification

    when_i_enter_the_course_dates("01/09/2027", "01/09/2030")
    then_i_am_asked_to_confirm_the_longer_course

    when_i_confirm_the_longer_course
    then_the_confirm_page_shows_the_course_length
    and_the_declaration_is_saved
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

  def then_i_am_asked_to_confirm_the_longer_course
    expect(page).to have_css(".govuk-error-summary", text: "Confirm the course is longer than 2 years")
    expect(page).to have_text("The trainee holds a level 5 qualification, so the course is usually 2 years. " \
                              "The dates you entered make it 3 years (1 September 2027 to 1 September 2030).")
    expect(page).not_to have_text("The expected end date must be between")
  end

  def when_i_confirm_the_longer_course
    check("I confirm the course is longer than 2 years")
    click_on("Continue")
  end

  def then_the_confirm_page_shows_the_course_length
    expect(page).to have_text("Course length")
    expect(page).to have_text("3 years")
    expect(page).to have_text("Confirmed as longer than the usual 2 years for a trainee with a level 5 qualification")
  end

  def and_the_declaration_is_saved
    expect(trainee.reload).to have_attributes(itt_end_date: Date.new(2030, 9, 1), extended_course_confirmed: true)
  end

  def then_i_see_the_confirm_page_without_a_course_length
    expect(page).to have_text("Confirm trainee’s course details").or have_text("Confirm trainee's course details")
    expect(page).not_to have_text("Course length")
  end
end
