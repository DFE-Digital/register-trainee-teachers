# frozen_string_literal: true

require "rails_helper"

feature "Recommending for QTS", type: :feature do
  include TraineeHelper

  scenario "redirects to the 'Recommended for QTS' page" do
    given_i_am_authenticated
    and_a_trainee_exists_ready_for_qts
    when_i_record_the_outcome_date
    and_i_confirm_the_outcome_details
    then_the_trainee_is_recommended_for_qts
  end

  def then_the_trainee_is_recommended_for_qts
    expect(page).to have_text("#{trainee_name(@trainee)} recommended for QTS")
  end

  def and_a_trainee_exists_ready_for_qts
    given_a_trainee_exists(:with_placement_assignment, :trn_received)
    stub_dttp_placement_assignment_request(outcome_date: Time.zone.today, status: 204)
  end

  def when_i_record_the_outcome_date
    outcome_date_edit_page.load(trainee_id: trainee.slug)
    outcome_date_edit_page.choose("Today")
    outcome_date_edit_page.continue.click
  end

  def and_i_confirm_the_outcome_details
    confirm_outcome_details_page.record_outcome.click
  end
end
