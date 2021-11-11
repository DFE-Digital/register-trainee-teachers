# frozen_string_literal: true

require "rails_helper"

feature "Withdrawing a trainee", type: :feature do
  include SummaryHelper

  context "validation errors" do
    before do
      when_i_am_on_the_withdrawal_page
    end

    scenario "no information provided" do
      and_i_continue
      then_i_see_the_error_message_for_date_not_chosen
      then_i_see_the_error_message_for_reason_not_chosen
    end

    scenario "invalid date for another day" do
      when_i_choose_another_day
      and_enter_an_invalid_date
      and_i_continue
      then_i_see_the_error_message_for_invalid_date
    end

    scenario "blank date for another day" do
      when_i_choose_another_day
      and_i_continue
      then_i_see_the_error_message_for_blank_date
    end
  end

  context "trainee withdrawn for specific reason" do
    background do
      when_i_am_on_the_withdrawal_page
      and_i_choose_a_specific_reason
    end

    scenario "today" do
      when_i_choose_today
      and_i_continue
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_i_see_my_date(Time.zone.today)
      when_i_withdraw
      then_the_withdraw_date_and_reason_is_updated
    end

    scenario "yesterday" do
      when_i_choose_yesterday
      and_i_continue
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_i_see_my_date(Time.zone.yesterday)
      when_i_withdraw
      then_the_withdraw_date_and_reason_is_updated
    end

    scenario "on another day" do
      when_i_choose_another_day
      and_i_enter_a_valid_date
      and_i_continue
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_i_see_my_date(@chosen_date)
      when_i_withdraw
      then_the_withdrawal_details_is_updated
    end
  end

  context "trainee withdrawn for another reason" do
    background do
      when_i_am_on_the_withdrawal_page
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

  scenario "cancelling changes" do
    when_i_am_on_the_withdrawal_page
    and_i_choose_today
    and_i_choose_a_specific_reason
    and_i_continue
    then_i_am_redirected_to_withdrawal_confirmation_page
    and_i_see_my_date(Time.zone.today)
    when_i_cancel_my_changes
    then_i_am_redirected_to_the_record_page
    and_the_withdrawal_information_i_set_is_cleared
  end

  scenario "when the trainee is deferred" do
    given_i_am_authenticated
    given_a_deferred_trainee_exists
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw
    then_the_deferral_text_should_be_shown
    when_i_choose_a_specific_reason
    and_i_continue
    then_i_am_redirected_to_withdrawal_confirmation_page
    and_the_deferral_date_is_used
  end

  def when_i_am_on_the_withdrawal_page
    given_i_am_authenticated
    given_a_trainee_exists_to_be_withdrawn
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw
  end

  def when_i_choose_today
    when_i_choose("Today")
  end

  alias_method :and_i_choose_today, :when_i_choose_today

  def when_i_choose_yesterday
    when_i_choose("Yesterday")
  end

  def when_i_choose_another_day
    when_i_choose("On another day")
  end

  def and_i_enter_a_valid_date
    @chosen_date = valid_date_after_course_start_date
    @chosen_date.tap do |withdraw_date|
      withdrawal_page.set_date_fields(:withdraw_date, withdraw_date.strftime("%d/%m/%Y"))
    end
  end

  def when_i_choose(option)
    withdrawal_page.choose(option)
  end

  def and_i_continue
    withdrawal_page.continue.click
  end

  def and_i_click_on_withdraw
    record_page.withdraw.click
  end

  def when_i_withdraw
    withdrawal_confirmation_page.withdraw.click
  end

  def and_enter_an_invalid_date
    withdrawal_page.set_date_fields(:withdraw_date, "32/01/2020")
  end

  def and_i_choose_a_specific_reason
    label = I18n.t("views.forms.withdrawal_reasons.labels.#{WithdrawalReasons::SPECIFIC.sample}")
    withdrawal_page.choose(label)
  end

  alias_method :when_i_choose_a_specific_reason, :and_i_choose_a_specific_reason

  def and_i_choose_for_another_reason
    label = I18n.t("views.forms.withdrawal_reasons.labels.#{WithdrawalReasons::FOR_ANOTHER_REASON}")
    withdrawal_page.choose(label)
  end

  def and_i_provide_a_reason
    withdrawal_page.additional_withdraw_reason.set(additional_withdraw_reason)
  end

  def then_i_see_the_error_message_for_date_not_chosen
    expect(withdrawal_page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.date_string.blank"),
    )
  end

  def then_i_see_the_error_message_for_invalid_date
    expect(withdrawal_page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.date.invalid"),
    )
  end

  def then_i_see_the_error_message_for_blank_date
    expect(withdrawal_page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.date.blank"),
    )
  end

  def then_i_see_the_error_message_for_reason_not_chosen
    expect(withdrawal_page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.withdraw_reason.invalid"),
    )
  end

  def then_i_see_the_error_message_for_missing_additional_reason
    expect(withdrawal_page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.additional_withdraw_reason.blank"),
    )
  end

  def then_the_withdrawal_details_is_updated
    trainee.reload
    expect(withdrawal_page).to have_text(date_for_summary_view(trainee.withdraw_date))
  end

  def then_i_am_redirected_to_withdrawal_confirmation_page
    expect(withdrawal_confirmation_page).to be_displayed(id: trainee.slug)
  end

  def then_the_withdraw_date_and_reason_is_updated
    trainee.reload
    expect(withdrawal_page).to have_text(trainee.withdraw_date.strftime("%-d %B %Y"))
  end

  def and_the_additional_reason_is_displayed
    trainee.reload
    expect(withdrawal_confirmation_page).to have_text(additional_withdraw_reason)
  end

  def given_a_trainee_exists_to_be_withdrawn
    given_a_trainee_exists(%i[submitted_for_trn trn_received].sample, commencement_date: 10.days.ago)
  end

  def given_a_deferred_trainee_exists
    given_a_trainee_exists(:deferred)
  end

  def additional_withdraw_reason
    @additional_withdraw_reason ||= Faker::Lorem.paragraph
  end

  def when_i_cancel_my_changes
    withdrawal_confirmation_page.cancel.click
  end

  def then_i_am_redirected_to_the_record_page
    expect(record_page).to be_displayed(id: trainee.slug)
  end

  def and_the_withdrawal_information_i_set_is_cleared
    trainee.reload
    expect(trainee.withdraw_date).to be_nil
    expect(trainee.withdraw_reason).to be_nil
    expect(trainee.additional_withdraw_reason).to be_nil
  end

  def then_the_deferral_text_should_be_shown
    expect(withdrawal_page).to have_deferral_notice
  end

  def and_the_deferral_date_is_used
    expect(withdrawal_confirmation_page).to have_text(
      t("components.confirmation.withdrawal_details.withdrawal_date", date: date_for_summary_view(trainee.defer_date)),
    )
  end
end
