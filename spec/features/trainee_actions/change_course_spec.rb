# frozen_string_literal: true

require "rails_helper"

feature "Change course", type: :feature, feature_publish_course_details: true do
  scenario "TRN received" do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received
    and_trainee_related_courses_exist
    and_i_am_on_the_trainee_record_page
    when_i_click_to_change_course_details
    and_i_choose_a_different_course
    and_i_click_continue
    and_select_a_specialism_if_necessary
    and_i_see_course_end_date_missing_error
    and_i_click_enter_answer_for_course_end_date
    and_i_enter_course_end_date
    and_i_submit_the_course_details_form
    and_i_click_update_record
    then_the_trainee_course_has_changed
  end

private

  def and_trainee_related_courses_exist
    @different_course = create(:course_with_subjects,
                               accredited_body_code: trainee.provider.code,
                               route: trainee.training_route)
    create(:subject_specialism, name: @different_course.name)
  end

  def and_a_trainee_exists_with_trn_received
    given_a_trainee_exists(:trn_received, :with_publish_course_details, :with_secondary_education)
  end

  def when_i_click_to_change_course_details
    record_page.change_course_details.click
  end

  def and_i_choose_a_different_course
    publish_course_details_page.course_options.find { |o| o.label.text.include?(@different_course.name) }.choose
  end

  def and_i_click_continue
    publish_course_details_page.submit_button.click
  end

  def and_i_click_update_record
    confirm_publish_course_details_page.continue_button.click
  end

  def and_select_a_specialism_if_necessary
    if page.current_path.include?("subject-specialism")
      subject_specialism_page.specialism_options.sample.choose
      subject_specialism_page.submit_button.click
    end

    if page.current_path.include?("language-specialism")
      language_specialism_page.language_specialism_options.sample.check
      language_specialism_page.submit_button.click
    end
  end

  def then_the_trainee_course_has_changed
    expect(trainee.reload.course_code).to eq(@different_course.code)
  end

  def and_i_see_course_end_date_missing_error
    expect(confirm_publish_course_details_page).to have_content("Course end date is missing")
  end

  def and_i_click_enter_answer_for_course_end_date
    form = CourseDetailsForm.new(trainee)
    [form.course_subject_one, form.course_subject_two, form.course_subject_three].flatten.select(&:present?).each do |name|
      create(:subject_specialism, name: name)
    end
    confirm_publish_course_details_page.enter_an_answer_for_course_end_date_link.click
  end

  def and_i_enter_course_end_date
    if course_details_page.text.include?("ITT end date")
      course_details_page.set_date_fields("itt_end_date", 1.year.from_now.strftime("%d/%m/%Y"))
    else
      course_details_page.set_date_fields("course_end_date", 1.year.from_now.strftime("%d/%m/%Y"))
    end
  end

  def and_i_submit_the_course_details_form
    course_details_page.submit_button.click
  end
end
