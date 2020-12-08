# frozen_string_literal: true

require "rails_helper"

feature "Recommending for QTS", type: :feature do
  before do
    given_i_am_authenticated
    given_a_trainee_exists
    when_i_record_the_outcome_date
    when_i_confirm_the_outcome_details
  end

  scenario "redirects to the 'Recommended for QTS' page" do
    expect(page).to have_text("Trainee recommended for QTS")
  end

  def when_i_record_the_outcome_date
    outcome_date_page.load(trainee_id: trainee.id)
    outcome_date_page.choose("Today")
    outcome_date_page.continue.click
  end

  def when_i_confirm_the_outcome_details
    confirm_page.continue.click
  end

  def outcome_date_page
    @outcome_date_page ||= PageObjects::Trainees::EditOutcomeDate.new
  end

  def confirm_page
    @confirm_page ||= PageObjects::Trainees::ConfirmOutcomeDetails.new
  end
end
