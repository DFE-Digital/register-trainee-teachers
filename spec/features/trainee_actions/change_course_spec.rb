# frozen_string_literal: true

require "rails_helper"

feature "Change course", feature_publish_course_details: true do
  include CourseDetailsHelper

  let(:itt_start_date) { Date.new(Settings.current_recruitment_cycle_year, 9, 1) }
  let(:itt_end_date) { itt_start_date + 1.year }

  scenario "TRN received" do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received
    and_trainee_related_courses_exist
    and_i_am_on_the_trainee_record_page
    when_i_click_to_change_course_details
    and_i_do_not_change_training_route
    and_i_choose_a_different_course
    and_i_click_continue
    and_select_a_specialism_if_necessary
    and_i_enter_itt_dates
    and_i_click_update_record
    then_the_trainee_course_has_changed
  end

  scenario "published course not selected", skip: skip_test_due_to_first_day_of_current_academic_year? do
    given_i_am_authenticated
    and_a_trainee_exists_for_valid_itt_start_date
    and_trainee_related_courses_exist
    and_courses_on_another_route_exist
    and_i_am_on_the_trainee_record_page
    when_i_click_to_change_course_details
    and_i_choose_a_different_training_route
    and_i_am_redirected_to_the_publish_course_details_page
  end

  context "given a draft trainee" do
    scenario "show course year choice", feature_show_draft_trainee_course_year_choice: true do
      given_i_am_authenticated
      and_a_draft_trainee_exists
      and_i_am_on_the_confirm_course_details_page
      and_i_click_change_course
      and_i_do_not_change_training_route
      i_am_redirected_to_the_change_course_year_page
    end

    scenario "do not show course year choice", feature_show_draft_trainee_course_year_choice: false do
      given_i_am_authenticated
      and_a_draft_trainee_exists
      and_i_am_on_the_confirm_course_details_page
      and_i_click_change_course
      and_i_do_not_change_training_route
      and_i_am_redirected_to_the_publish_course_details_page
    end

    context "within 1 month of the next cycle" do
      around do |example|
        Timecop.freeze(Date.new(Time.zone.today.year, 7, 15)) { example.run }
      end

      scenario "do not show course year choice and default to next cycle", feature_show_draft_trainee_course_year_choice: false, skip: skip_test_due_to_first_day_of_current_academic_year? do
        given_i_am_authenticated
        and_a_draft_trainee_exists
        and_i_am_on_the_confirm_course_details_page
        and_i_click_change_course
        and_i_do_not_change_training_route
        and_i_am_redirected_to_the_publish_course_details_page
        then_i_can_pick_a_course_from_the_next_cycle
      end
    end
  end

private

  def and_i_am_on_the_confirm_course_details_page
    confirm_course_details_page.load(id: trainee.slug)
  end

  def and_i_click_change_course
    confirm_course_details_page.course_link.click
  end

  def i_am_redirected_to_the_change_course_year_page
    expect(course_years_page).to be_displayed
  end

  def i_am_redirected_to_the_training_routes_page
    expect(trainee_edit_training_route_page).to be_displayed
  end

  def and_trainee_related_courses_exist
    @different_course = create(:course_with_subjects,
                               :secondary,
                               accredited_body_code: trainee.provider.code,
                               route: trainee.training_route)
    create(:subject_specialism, name: @different_course.name)
  end

  def and_courses_on_another_route_exist
    create(:course_with_subjects,
           :secondary,
           accredited_body_code: trainee.provider.code,
           route: "provider_led_postgrad",
           recruitment_cycle_year: trainee.start_academic_cycle.start_year)
  end

  def and_a_draft_trainee_exists
    given_a_trainee_exists(:draft, :with_publish_course_details, :pg_teaching_apprenticeship, :with_secondary_education)
  end

  def and_a_trainee_exists_with_trn_received
    given_a_trainee_exists(:trn_received, :with_publish_course_details, :pg_teaching_apprenticeship, :with_secondary_education)
  end

  def and_a_trainee_exists
    given_a_trainee_exists(:trn_received, :pg_teaching_apprenticeship, :with_secondary_education)
  end

  def and_a_trainee_exists_for_valid_itt_start_date
    given_a_trainee_exists(:trn_received, :pg_teaching_apprenticeship, :with_secondary_education, :with_valid_itt_start_date)
  end

  def when_i_click_to_change_course_details
    record_page.change_course_details.click
  end

  def and_i_do_not_change_training_route
    trainee_edit_training_route_page.continue_button.click
  end

  def and_i_choose_a_different_training_route
    trainee_edit_training_route_page.training_route_options.find { |o|
      o.input.value.include?("provider_led_postgrad")
    }.choose
    trainee_edit_training_route_page.continue_button.click
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
      language_specialism = language_specialism_options.to_h.keys.compact_blank.sample
      language_specialism_page.language_select_one.select(language_specialism)
      language_specialism_page.submit_button.click
    end
  end

  def then_the_trainee_course_has_changed
    expect(trainee.reload.course_uuid).to eq(@different_course.uuid)
  end

  def and_i_submit_the_course_details_form
    course_details_page.submit_button.click
  end

  def then_i_am_redirected_to_the_course_years_page
    expect(course_years_page).to be_displayed(id: trainee.slug)
  end

  def and_i_choose_a_different_year
    course_years_page.choose("#{itt_start_date.year} to #{itt_end_date.year}")
    course_years_page.continue.click
  end

  def and_i_am_redirected_to_the_publish_course_details_page
    expect(publish_course_details_page).to be_displayed(id: trainee.slug)
  end

  def then_i_can_pick_a_course_from_the_next_cycle
    expect(publish_course_details_page.title).to include(
      "Your teaching apprenticeship postgrad courses starting in #{Settings.current_recruitment_cycle_year} to #{Settings.current_recruitment_cycle_year + 1}",
    )
  end
end
