# frozen_string_literal: true

require "rails_helper"

feature "Recording withdrawing training", type: :feature do
  include SummaryHelper

  background do
    given_i_am_authenticated
    given_a_trainee_exists
    and_i_am_on_the_trainee_edit_page
    and_i_click_on_withdraw
  end

  context "validation errors" do
    scenario "no information provided" do
      and_i_continue
      then_i_see_the_error_message_for_invalid_date
      then_i_see_the_error_message_for_invalid_reason
    end

    scenario "invalid date for another day" do
      when_i_choose_another_day
      and_enter_an_invalid_date
      and_i_continue
      then_i_see_the_error_message_for_invalid_date
    end
  end

  context "trainee withdrawn for specific reason" do
    background do
      and_i_choose_a_specific_reason
    end

    scenario "today" do
      when_i_choose_today
      and_i_continue
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_the_withdraw_date_and_reason_is_updated
    end

    scenario "yesterday" do
      when_i_choose_yesterday
      and_i_continue
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_the_withdraw_date_and_reason_is_updated
    end

    scenario "on another day" do
      when_i_choose_another_day
      and_i_enter_a_valid_date
      and_i_continue
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_the_withdrawal_details_is_updated
    end
  end

  context "trainee withdrawn for another reason" do
    background do
      and_i_choose_for_another_reason
    end

    scenario "and that reason is provided" do
      when_i_choose_today
      and_i_provide_a_reason
      and_i_continue
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_the_additional_reason_is_displayed
    end

    scenario "and a reason is not provided" do
      and_i_continue
      then_i_see_the_error_message_for_missing_additional_reason
    end
  end

  def when_i_choose_today
    when_i_choose("Today")
  end

  def when_i_choose_yesterday
    when_i_choose("Yesterday")
  end

  def when_i_choose_another_day
    when_i_choose("On another day")
  end

  def and_i_enter_a_valid_date
    Faker::Date.in_date_period.tap do |withdraw_date|
      withdrawal_page.set_date_fields(:withdraw_date, withdraw_date.strftime("%d/%m/%Y"))
    end
  end

  def and_i_am_on_the_trainee_edit_page
    edit_page.load(id: trainee.id)
  end

  def when_i_choose(option)
    withdrawal_page.choose(option)
  end

  def and_i_continue
    withdrawal_page.continue.click
  end

  def and_i_click_on_withdraw
    edit_page.withdraw.click
  end

  def and_enter_an_invalid_date
    withdrawal_page.set_date_fields(:withdraw_date, "32/01/2020")
  end

  def and_i_choose_a_specific_reason
    label = I18n.t("views.forms.withdrawal_reasons.labels.#{WithdrawalReasons::SPECIFIC.sample}")
    withdrawal_page.choose(label)
  end

  def and_i_choose_for_another_reason
    label = I18n.t("views.forms.withdrawal_reasons.labels.#{WithdrawalReasons::FOR_ANOTHER_REASON}")
    withdrawal_page.choose(label)
  end

  def and_i_provide_a_reason
    withdrawal_page.additional_withdraw_reason.set(additional_withdraw_reason)
  end

  def then_i_see_the_error_message_for_invalid_date
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.withdraw_date.invalid"),
    )
  end

  def then_i_see_the_error_message_for_invalid_reason
    expect(withdrawal_page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.withdraw_reason.invalid"),
    )
  end

  def then_i_see_the_error_message_for_missing_additional_reason
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.additional_withdraw_reason.blank"),
    )
  end

  def and_the_withdrawal_details_is_updated
    trainee.reload
    expect(page).to have_text(date_for_summary_view(trainee.withdraw_date))
  end

  def then_i_am_redirected_to_withdrawal_confirmation_page
    expect(withdrawal_confirmation_page).to be_displayed(id: trainee.id)
  end

  def and_the_withdraw_date_and_reason_is_updated
    trainee.reload
    expect(page).to have_text(trainee.withdraw_date.strftime("%-d %B %Y"))
    reason = I18n.t("components.confirmation.withdrawal_details.reasons.#{trainee.withdraw_reason}")
    expect(page).to have_text(reason)
  end

  def and_the_additional_reason_is_displayed
    trainee.reload
    expect(withdrawal_confirmation_page).to have_text(additional_withdraw_reason)
  end

  def edit_page
    @edit_page ||= PageObjects::Trainees::Edit.new
  end

  def withdrawal_page
    @withdrawal_page ||= PageObjects::Trainees::Withdrawal.new
  end

  def withdrawal_confirmation_page
    @withdrawal_confirmation_page ||= PageObjects::Trainees::ConfirmWithdrawal.new
  end

  def additional_withdraw_reason
    @additional_withdraw_reason ||= Faker::Lorem.paragraph
  end
end
