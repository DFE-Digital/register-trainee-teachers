# frozen_string_literal: true

require "rails_helper"

feature "course education phase", type: :feature do
  include SummaryHelper

  background { given_i_am_authenticated }

  context "trainee has no existing course education phase" do
    scenario "submitting with invalid parameters" do
      given_a_trainee_exists
      when_i_visit_the_course_education_phase_page
      and_i_submit_the_form
      then_i_see_error_messages
    end
  end

  scenario "submitting with valid parameters" do
    given_a_trainee_exists_with_course_details
    when_i_visit_the_course_education_phase_page
    and_i_choose_a_phase
    and_i_submit_the_form
    then_i_am_redirected_to_the_edit_course_details_page
  end

private

  def given_a_trainee_exists_with_course_details
    given_a_trainee_exists(:with_course_details, :with_primary_education)
  end

  def when_i_visit_the_course_education_phase_page
    course_education_phase_page.load(id: trainee.slug)
  end

  def and_i_choose_a_phase
    course_education_phase_page.primary_phase.choose
  end

  def and_i_submit_the_form
    course_education_phase_page.submit_button.click
  end

  def then_i_am_redirected_to_the_edit_course_details_page
    expect(course_details_page).to be_displayed(id: trainee.slug)
  end

  def then_i_see_error_messages
    translation_key_prefix = "activemodel.errors.models.course_education_phase_form.attributes"

    expect(course_details_page).to have_content(
      I18n.t("#{translation_key_prefix}.course_education_phase.blank"),
    )
  end
end
