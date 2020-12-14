# frozen_string_literal: true

require "rails_helper"

feature "Recommending for QTS", type: :feature do
  scenario "redirects to the 'Recommended for QTS' page" do
    given_i_am_authenticated
    and_a_trainee_exists_ready_for_qts
    when_i_record_the_outcome_date
    and_i_confirm_the_outcome_details
    then_the_trainee_is_recommended_for_qts
  end

  def then_the_trainee_is_recommended_for_qts
    expect(page).to have_text("Trainee recommended for QTS")
  end

  def and_a_trainee_exists_ready_for_qts
    given_a_trainee_exists(:with_placement_assignment)
    stub_dttp_placement_assignment_request(outcome_date: Time.zone.today, status: 204)
  end

  def when_i_record_the_outcome_date
    outcome_date_page.load(trainee_id: trainee.id)
    outcome_date_page.choose("Today")
    outcome_date_page.continue.click
  end

  def and_i_confirm_the_outcome_details
    confirm_page.continue.click
  end

  def outcome_date_page
    @outcome_date_page ||= PageObjects::Trainees::EditOutcomeDate.new
  end

  def confirm_page
    @confirm_page ||= PageObjects::Trainees::ConfirmOutcomeDetails.new
  end
end
