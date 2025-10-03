# frozen_string_literal: true

require "rails_helper"

feature "Create trainee journey" do
  background do
    given_i_am_authenticated
    when_i_am_viewing_the_list_of_trainees
    and_i_click_on_add_trainee_button
  end

  scenario "setting up an initial assessment only record" do
    and_i_select_assessment_only_route
    and_i_save_the_form
    then_i_should_see_the_new_trainee_overview
    and_trainee_record_source_is_set_to_manual
  end

  scenario "setting up an initial provider led record" do
    and_i_select_provider_led_postgrad_route
    and_i_save_the_form
    then_i_should_see_the_new_trainee_overview
  end

  scenario "setting up an initial early years undergrad record" do
    and_i_select_early_years_undergrad_route
    and_i_save_the_form
    then_i_should_see_the_new_trainee_overview
    and_trainee_course_subject_one_set_to_early_years_teaching
  end

  scenario "school direct tuition fee radio button should not be shown" do
    and_i_should_not_see_school_direct_tuition_fee_route
  end

  scenario "submitting without choosing a route" do
    and_i_save_the_form
    then_i_should_see_a_validation_error
  end

  scenario "setting up a Teacher Degree Apprenticeship record" do
    and_i_select_teacher_degree_apprenticeship_route
    and_i_save_the_form
    then_i_should_see_the_new_trainee_overview
    and_trainee_record_source_is_set_to_manual
  end

private

  def when_i_am_viewing_the_list_of_trainees
    trainee_index_page.load
  end

  def and_i_click_on_add_trainee_button
    trainee_index_page.add_trainee_link.click
  end

  def and_i_select_assessment_only_route
    new_trainee_page.assessment_only.click
  end

  def and_i_select_provider_led_postgrad_route
    new_trainee_page.provider_led_postgrad.click
  end

  def and_i_select_early_years_undergrad_route
    new_trainee_page.early_years_undergrad.click
  end

  def and_i_select_teacher_degree_apprenticeship_route
    new_trainee_page.teacher_degree_apprenticeship.click
  end

  def and_i_should_not_see_school_direct_tuition_fee_route
    expect(new_trainee_page).to be_displayed
    expect(new_trainee_page).not_to have_school_direct_tuition_fee
  end

  def and_i_save_the_form
    new_trainee_page.continue_button.click
  end

  def then_i_should_see_the_new_trainee_overview
    expect(review_draft_page).to be_displayed
  end

  def then_i_should_see_a_validation_error
    expect(new_trainee_page).to have_content(I18n.t("activerecord.errors.models.trainee.attributes.training_route"))
  end

  def and_trainee_course_subject_one_set_to_early_years_teaching
    expect(Trainee.last.course_subject_one).to eq(CourseSubjects::EARLY_YEARS_TEACHING)
    expect(Trainee.last.course_age_range).to eq(DfE::ReferenceData::AgeRanges::ZERO_TO_FIVE)
  end

  def and_trainee_record_source_is_set_to_manual
    expect(Trainee.last.manual_record?).to be(true)
  end
end
