# frozen_string_literal: true

require "rails_helper"

feature "Recording a training outcome", type: :feature do
  include SummaryHelper

  before do
    given_i_am_authenticated
    given_a_trainee_exists(state: :trn_received)
    and_i_am_on_the_trainee_record_page
    and_i_click_on_record_training_outcome
  end

  scenario "submit empty form" do
    and_i_submit_the_form
    then_i_see_the_error_message_for_date_not_chosen
  end

  scenario "choosing today records the outcome" do
    when_i_choose_today
    and_i_submit_the_form
    then_i_am_redirected_to_the_confirm_page
    and_the_outcome_date_is_updated
  end

  scenario "choosing yesterday records the outcome" do
    when_i_choose_yesterday
    and_i_submit_the_form
    then_i_am_redirected_to_the_confirm_page
    and_the_outcome_date_is_updated
  end

  context "choosing 'On another day'" do
    before do
      when_i_choose("On another day")
    end

    scenario "and not filling out a complete date displays the correct error" do
      and_i_submit_the_form
      then_i_see_the_error_message_for("blank")
    end

    scenario "and filling out an invalid date displays the correct error" do
      outcome_date_page.set_date_fields("outcome_date", "32/01/2020")
      and_i_submit_the_form
      then_i_see_the_error_message_for("invalid")
    end

    scenario "and filling out a valid date" do
      when_i_chose_a_specific_date
      and_i_submit_the_form
      then_i_am_redirected_to_the_confirm_page
      and_the_outcome_date_is_updated
    end
  end

  def when_i_choose_today
    stub_dttp_placement_assignment_request(outcome_date: Time.zone.today, status: 204)
    when_i_choose("Today")
  end

  def when_i_choose_yesterday
    stub_dttp_placement_assignment_request(outcome_date: Time.zone.yesterday, status: 204)
    when_i_choose("Yesterday")
  end

  def when_i_chose_a_specific_date
    outcome_date = Faker::Date.in_date_period
    stub_dttp_placement_assignment_request(outcome_date: outcome_date, status: 204)
    outcome_date_page.set_date_fields("outcome_date", outcome_date.strftime("%d/%m/%Y"))
  end

  def and_i_am_on_the_trainee_record_page
    record_page.load(id: trainee.id)
  end

  def and_i_click_on_record_training_outcome
    record_page.record_outcome.click
  end

  def when_i_choose(option)
    outcome_date_page.choose(option)
  end

  def and_i_submit_the_form
    outcome_date_page.continue.click
  end

  def then_i_see_the_error_message_for(type)
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.outcome_date_form.attributes.outcome_date.#{type}"),
    )
  end

  def then_i_see_the_error_message_for_date_not_chosen
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.outcome_date_form.attributes.outcome_date_string.blank"),
    )
  end

  def then_i_am_redirected_to_the_confirm_page
    expect(confirm_page).to be_displayed(id: trainee.id)
  end

  def and_the_outcome_date_is_updated
    trainee.reload
    expect(page).to have_text(date_for_summary_view(trainee.outcome_date))
  end

  def record_page
    @record_page ||= PageObjects::Trainees::Record.new
  end

  def outcome_date_page
    @edit_outcome_date_page ||= PageObjects::Trainees::EditOutcomeDate.new
  end

  def confirm_page
    @confirm_page ||= PageObjects::Trainees::ConfirmOutcomeDetails.new
  end
end
