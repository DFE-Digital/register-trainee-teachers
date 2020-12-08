# frozen_string_literal: true

require "rails_helper"

feature "Recording a training outcome", type: :feature do
  include SummaryHelper

  before do
    given_i_am_authenticated
    given_a_trainee_exists
    when_i_visit_the_trainee_edit_page
    when_i_click_on_record_training_outcome
  end

  scenario "choosing today records the outcome" do
    when_i_choose("Today")
    when_i_submit_the_form
    then_i_am_redirected_to_the_confirm_page
    then_the_outcome_date_is_updated
  end

  scenario "choosing yesterday records the outcome" do
    when_i_choose("Yesterday")
    when_i_submit_the_form
    then_i_am_redirected_to_the_confirm_page
    then_the_outcome_date_is_updated
  end

  context "choosing 'On another day'" do
    before do
      when_i_choose("On another day")
    end

    scenario "and not filling out a complete date displays the correct error" do
      when_i_submit_the_form
      then_i_see_the_error_message_for("blank")
    end

    scenario "and filling out an invalid date displays the correct error" do
      outcome_date_page.set_date_fields("outcome_date", "32/01/2020")
      when_i_submit_the_form
      then_i_see_the_error_message_for("invalid")
    end

    scenario "and filling out a valid date" do
      outcome_date_page.set_date_fields("outcome_date", "31/01/2020")
      when_i_submit_the_form
      then_i_am_redirected_to_the_confirm_page
      then_the_outcome_date_is_updated
    end
  end

  def when_i_visit_the_trainee_edit_page
    edit_page.load(id: trainee.id)
  end

  def when_i_click_on_record_training_outcome
    edit_page.record_outcome.click
  end

  def when_i_choose(option)
    outcome_date_page.choose(option)
  end

  def when_i_submit_the_form
    outcome_date_page.continue.click
  end

  def then_i_see_the_error_message_for(type)
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.outcome_date.attributes.outcome_date_string.#{type}"),
    )
  end

  def then_i_am_redirected_to_the_confirm_page
    expect(confirm_page).to be_displayed(id: trainee.id)
  end

  def then_the_outcome_date_is_updated
    trainee.reload
    expect(page).to have_text(date_for_summary_view(trainee.outcome_date))
  end

  def edit_page
    @edit_page ||= PageObjects::Trainees::Edit.new
  end

  def outcome_date_page
    @edit_outcome_date_page ||= PageObjects::Trainees::EditOutcomeDate.new
  end

  def confirm_page
    @confirm_page ||= PageObjects::Trainees::ConfirmOutcomeDate.new
  end
end
