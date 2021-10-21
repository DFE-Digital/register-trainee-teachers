# frozen_string_literal: true

require "rails_helper"

feature "edit training details" do
  include SummaryHelper

  let(:new_trainee_id) { "#{trainee.trainee_id}new" }
  let(:new_start_date) { Date.tomorrow }

  background { given_i_am_authenticated }

  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_training_details_page
    and_i_update_the_training_details
    then_i_am_redirected_to_the_confirm_training_details_page
    and_the_training_details_are_updated
  end

  context "edit with course details" do
    scenario "choose course start date" do
      given_a_trainee_exists(:with_secondary_course_details)
      when_i_visit_the_training_details_page
      and_i_choose_course_start_date
      then_i_am_redirected_to_the_confirm_training_details_page
      and_the_training_details_are_updated_with_course_start_date
    end

    scenario "choose custom date" do
      given_a_trainee_exists(:with_secondary_course_details)
      when_i_visit_the_training_details_page
      and_i_update_the_training_details
      and_i_choose_manual_start_date
      then_i_am_redirected_to_the_confirm_training_details_page
      and_the_training_details_are_updated
    end
  end

  def when_i_visit_the_training_details_page
    training_details_page.load(id: trainee.slug)
  end

  def and_i_update_the_training_details
    training_details_page.trainee_id.set(new_trainee_id)
    training_details_page.set_date_fields(:commencement_date, new_start_date.strftime("%d/%m/%Y"))
    training_details_page.submit_button.click
  end

  def and_i_choose_course_start_date
    training_details_page.trainee_id.set(new_trainee_id)
    training_details_page.commencement_date_radio_option_course.choose
    training_details_page.submit_button.click
  end

  def and_i_choose_manual_start_date
    training_details_page.trainee_id.set(new_trainee_id)
    training_details_page.commencement_date_radio_option_manual.choose
    training_details_page.set_date_fields(:commencement_date, new_start_date.strftime("%d/%m/%Y"))
    training_details_page.submit_button.click
  end

  def and_the_training_details_are_updated
    expect(confirm_training_details_page).to have_text(new_trainee_id)
    expect(confirm_training_details_page).to have_text(date_for_summary_view(new_start_date))
  end

  def and_the_training_details_are_updated_with_course_start_date
    expect(confirm_training_details_page).to have_text(new_trainee_id)
    expect(confirm_training_details_page).to have_text(date_for_summary_view(Trainee.last.course_start_date))
  end

  def then_i_am_redirected_to_the_confirm_training_details_page
    expect(confirm_training_details_page).to be_displayed(id: trainee.slug)
  end
end
