# frozen_string_literal: true

require "rails_helper"

feature "Recommending for QTS" do
  include TraineeHelper

  scenario "updates the trainee status and shows success banner" do
    given_i_am_authenticated
    and_a_trainee_exists_ready_for_qts
    when_i_visit_the_trainee_record_page
    and_i_click_on_recommend_for_qts
    and_i_record_the_outcome_date
    and_i_confirm_the_outcome_details
    then_i_am_on_the_trainee_record_page
    and_i_see_the_success_banner
  end

  def then_i_am_on_the_trainee_record_page
    expect(record_page).to be_displayed(id: trainee.slug)
  end

  def and_i_see_the_success_banner
    expect(page).to have_text("Trainee’s QTS status updated")
  end

  def and_a_trainee_exists_ready_for_qts
    given_a_trainee_exists(
      :with_placement_assignment,
      :with_placements,
      :trn_received,
      :itt_start_date_in_the_past,
      :provider_led_postgrad,
    )
  end

  def when_i_visit_the_trainee_record_page
    visit trainee_path(trainee)
  end

  def and_i_click_on_recommend_for_qts
    click_on "Update QTS status"
  end

  def and_i_record_the_outcome_date
    outcome_date_edit_page.choose("Today")
    outcome_date_edit_page.continue.click
  end

  def and_i_confirm_the_outcome_details
    confirm_outcome_details_page.record_outcome.click
  end
end
