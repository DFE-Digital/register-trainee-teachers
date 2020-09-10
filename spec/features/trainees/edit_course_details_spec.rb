require "rails_helper"

feature "edit course details" do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_course_details_page
    and_i_enter_valid_parameters
    then_i_am_redirected_to_the_summary_page
  end

  def given_a_trainee_exists
    trainee
  end

  def when_i_visit_the_course_details_page
    course_details_page.load(id: @trainee.id)
  end

  def and_i_enter_valid_parameters
    course_details_page.course_title.set "Test Course"
    course_details_page.course_phase.set "11-16"
    set_date_fields("programme_start_date", "10/01/2021")
    course_details_page.programme_length.set "1 year"
    set_date_fields("programme_end_date", "10/01/2022")
    course_details_page.allocation_subject.set "Maths"
    course_details_page.itt_subject.set "Maths"
    course_details_page.employing_school.set "Hillside College"
    course_details_page.placement_school.set "Northwich Academy"
    course_details_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    expect(summary_page).to be_displayed(id: trainee.id)
  end

  def set_date_fields(field_prefix, date_string)
    day, month, year = date_string.split("/")
    course_details_page.send("#{field_prefix}_day").set day
    course_details_page.send("#{field_prefix}_month").set month
    course_details_page.send("#{field_prefix}_year").set year
  end

  def course_details_page
    @course_details_page ||= PageObjects::Trainees::CourseDetails.new
  end

  def summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
  end

  def trainee
    @trainee ||= create(:trainee)
  end
end
