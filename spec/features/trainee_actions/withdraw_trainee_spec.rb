# frozen_string_literal: true

require "rails_helper"

feature "Withdrawing a trainee" do
  include_context "perform enqueued jobs"
  include SummaryHelper

  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  let!(:withdrawal_reason_provider) { create(:withdrawal_reason, :provider) }
  let!(:withdrawal_reason_trainee) { create(:withdrawal_reason, :trainee) }
  let!(:withdrawal_reason_safeguarding) { create(:withdrawal_reason, :safeguarding) }
  let!(:withdrawal_reason_unknown) { create(:withdrawal_reason, :unknown) }
  let!(:withdrawal_reason_another_reason) { create(:withdrawal_reason, :another_reason) }

  context "validation errors" do
    before do
      given_i_am_authenticated
      given_a_trainee_exists_to_be_withdrawn
    end

    scenario "no date provided" do
      when_i_am_on_the_date_page
      and_i_continue(:date)
      then_i_see_the_error_message_for_date_not_chosen
    end

    scenario "no reason provided" do
      when_i_am_on_the_reason_page
      and_i_continue(:reason)
      then_i_see_the_error_message_for_reason_not_chosen
    end

    scenario "no trigger provided" do
      when_i_am_on_the_trigger_page
      and_i_continue(:trigger)
      then_i_see_the_error_message_for_trigger_not_chosen
    end

    scenario "no future interest provided" do
      when_i_am_on_the_future_interest_page
      and_i_continue(:future_interest)
      then_i_see_the_error_message_for_future_interest_not_chosen
    end
  end

  context "trainee withdrawn" do
    before do
      when_i_am_on_the_withdrawal_page
    end

    let(:reason) { withdrawal_reason_trainee.name }
    let(:start_date) { trainee.trainee_start_date }

    context "today" do
      let(:withdrawal_date) { Time.zone.today }

      scenario "successfully" do
        when_i_choose_today
        and_i_continue(:date)
        when_i_choose_trainee_chose_to_withdraw
        and_i_continue(:trigger)
        when_i_check_a_reason
        and_i_continue(:reason)
        when_i_choose_future_interest
        and_i_continue(:future_interest)
        then_i_am_redirected_to_withdrawal_confirmation_page
        and_i_see_the_summary_card(withdrawal_date:, reason:)
        and_i_continue(:confirm_detail)
        then_i_am_redirected_to_the_record_page
        and_i_see_the_summary_card(withdrawal_date:, reason:)
      end
    end

    context "yesterday", skip: skip_test_due_to_first_day_of_current_academic_year? do
      let(:withdrawal_date) { Time.zone.yesterday }

      scenario "successfully" do
        when_i_choose_yesterday
        and_i_continue(:date)
        when_i_choose_trainee_chose_to_withdraw
        and_i_continue(:trigger)
        when_i_check_a_reason
        and_i_continue(:reason)
        when_i_choose_future_interest
        and_i_continue(:future_interest)
        then_i_am_redirected_to_withdrawal_confirmation_page
        and_i_see_the_summary_card(withdrawal_date:, reason:)
        and_i_continue(:confirm_detail)
        then_i_am_redirected_to_the_record_page
        and_i_see_the_summary_card(withdrawal_date:, reason:)
      end
    end

    context "another date" do
      let(:withdrawal_date) { nil }

      scenario "successfully" do
        when_i_choose_another_day
        withdrawal_date = and_i_enter_a_valid_date
        and_i_continue(:date)
        when_i_choose_trainee_chose_to_withdraw
        and_i_continue(:trigger)
        when_i_check_a_reason
        and_i_continue(:reason)
        when_i_choose_future_interest
        and_i_continue(:future_interest)
        then_i_am_redirected_to_withdrawal_confirmation_page
        and_i_see_the_summary_card(withdrawal_date:, reason:)
        and_i_continue(:confirm_detail)
        then_i_am_redirected_to_the_record_page
        and_i_see_the_summary_card(withdrawal_date:, reason:)
      end
    end

    context "with safeguarding concerns" do
      let(:withdrawal_date) { nil }

      scenario "successfully" do
        when_i_choose_another_day
        withdrawal_date = and_i_enter_a_valid_date
        and_i_continue(:date)
        when_i_choose_trainee_chose_to_withdraw
        and_i_continue(:trigger)
        when_i_check_the_safeguarding_reason
        and_i_continue(:reason)
        then_i_see_validation_error_for_safeguarding_concern_reasons
        and_i_fill_in_details_for_safeguarding_concern_reasons
        and_i_continue(:reason)
        when_i_choose_future_interest
        and_i_continue(:future_interest)
        then_i_am_redirected_to_withdrawal_confirmation_page
        and_i_see_the_summary_card(start_date, withdrawal_date: withdrawal_date, reason: withdrawal_reason_safeguarding.name)
        and_i_can_see_the_safeguarding_concern_reasons_text
        and_i_continue(:confirm_detail)
        then_i_am_redirected_to_the_record_page
        and_i_see_the_summary_card(start_date, withdrawal_date: withdrawal_date, reason: withdrawal_reason_safeguarding.name)
        and_i_can_see_the_safeguarding_concern_reasons_text
      end
    end

    scenario "when DQT integration feature is active", feature_integrate_with_dqt: true do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      when_i_choose_today
      and_i_continue(:date)
      when_i_choose_trainee_chose_to_withdraw
      and_i_continue(:trigger)
      when_i_check_a_reason
      and_i_continue(:reason)
      when_i_choose_future_interest
      and_i_continue(:future_interest)
      and_i_continue(:confirm_detail)
      and_a_withdrawal_job_has_been_queued
    end
  end

  scenario "trainee has not started course" do
    given_i_am_authenticated
    given_a_trainee_exists_to_be_withdrawn_with_no_start_date
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw_and_continue
    and_i_choose_they_have_not_started
    then_i_am_taken_to_the_forbidden_withdrawal_page
  end

  scenario "trainee is withdrawn but there is no existing start date" do
    given_i_am_authenticated
    given_a_trainee_exists_to_be_withdrawn_with_no_start_date
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw
    and_i_choose_they_have_started
    when_i_choose_they_started_on_time
    then_i_should_be_on_the_withdrawal_page
  end

  scenario "cancelling changes" do
    when_i_am_on_the_withdrawal_page
    and_i_choose_today
    and_i_continue(:date)
    when_i_choose_trainee_chose_to_withdraw
    and_i_continue(:trigger)
    when_i_check_a_reason
    and_i_continue(:reason)
    when_i_choose_future_interest
    when_i_cancel_my_changes(:future_interest)
    then_i_am_redirected_to_the_record_page
    and_the_withdrawal_information_i_set_is_cleared
  end

  scenario "when the trainee is deferred" do
    given_i_am_authenticated
    given_a_deferred_trainee_exists
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw_and_continue
    when_i_choose_trainee_chose_to_withdraw
    and_i_continue(:trigger)
    then_the_deferral_text_should_be_shown
    when_i_check_a_reason
    and_i_continue(:reason)
    when_i_choose_future_interest
    and_i_continue(:future_interest)
    then_i_am_redirected_to_withdrawal_confirmation_page
    and_the_deferral_date_is_used
    and_i_continue(:confirm_detail)
    and_the_deferral_date_is_used
  end

  scenario "when the trainee is a duplicate" do
    given_i_am_authenticated
    given_a_trainee_exists_to_be_withdrawn
    and_the_trainee_has_a_duplicate
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw_and_continue
    then_the_duplicate_record_text_should_be_shown
  end

  scenario "trainee is already withdrawn" do
    given_i_am_authenticated
    given_a_trainee_exists_that_is_already_withdrawn
    and_i_am_on_the_trainee_record_page
    then_i_cannot_see_the_withdraw_link
    then_i_cannot_see_the_edit_withdrawal_link
  end

  scenario "as a system admin trainee is already withdrawn" do
    given_i_am_authenticated_as_system_admin
    given_a_trainee_exists_that_is_already_withdrawn
    and_i_am_on_the_trainee_record_page
    then_i_can_see_the_edit_withdrawal_details_component
  end

  def when_i_am_on_the_withdrawal_page
    given_i_am_authenticated
    given_a_trainee_exists_to_be_withdrawn
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw_and_continue
  end

  def when_i_am_on_the_date_page
    withdrawal_date_page.load(id: trainee.slug)
  end

  def when_i_am_on_the_trigger_page
    withdrawal_trigger_page.load(id: trainee.slug)
  end

  def when_i_am_on_the_reason_page
    allow(Withdrawal::TriggerForm).to receive(:new).and_return(instance_double(Withdrawal::TriggerForm, trigger: "trainee"))
    withdrawal_reason_page.load(id: trainee.slug)
  end

  def when_i_am_on_the_future_interest_page
    withdrawal_future_interest_page.load(id: trainee.slug)
  end

  def when_i_choose_today
    when_i_choose(:date, "Today")
  end

  alias_method :and_i_choose_today, :when_i_choose_today

  def when_i_choose_yesterday
    when_i_choose(:date, "Yesterday")
  end

  def when_i_choose_another_day
    when_i_choose(:date, "Another date")
  end

  def when_i_choose_trainee_chose_to_withdraw
    when_i_choose(:trigger, "The trainee chose to withdraw")
  end

  def when_i_choose_future_interest
    when_i_choose(:future_interest, "Yes")
  end

  def and_i_enter_a_valid_date
    @chosen_date = valid_date_after_itt_start_date
    @chosen_date.tap do |withdraw_date|
      withdrawal_date_page.set_date_fields(:withdrawal_date, withdraw_date.strftime("%d/%m/%Y"))
    end
    @chosen_date
  end

  def when_i_check_a_reason(reason = nil)
    if reason.nil?
      begin
        when_i_check(:reason, I18n.t("components.withdrawal_details.reasons.#{withdrawal_reason_provider.name}"))
      rescue Capybara::ElementNotFound
        when_i_check(:reason, I18n.t("components.withdrawal_details.reasons.#{withdrawal_reason_trainee.name}"))
      end
    else
      when_i_check(:reason, I18n.t("components.withdrawal_details.reasons.#{reason}"))
    end
  end

  def when_i_check_the_safeguarding_reason
    when_i_check(:reason, I18n.t("components.withdrawal_details.reasons.safeguarding_concerns"))
  end

  def then_i_see_validation_error_for_safeguarding_concern_reasons
    expect(page).to have_css(".govuk-error-message", text: /Enter the concerns/)
  end

  def and_i_fill_in_details_for_safeguarding_concern_reasons
    fill_in "Enter the concerns", with: "Some details about safeguarding concerns"
  end

  def when_i_choose(page, option)
    public_send("withdrawal_#{page}_page").choose(option)
  end

  def when_i_check(page, option)
    public_send("withdrawal_#{page}_page").check(option)
  end

  def and_i_continue(page)
    public_send("withdrawal_#{page}_page").continue.click
  end

  def and_i_click_on_withdraw_and_continue
    and_i_click_on_withdraw
    and_i_start_withdrawal
  end

  def and_i_click_on_withdraw
    record_page.withdraw.click
  end

  def and_i_start_withdrawal
    and_i_continue(:start)
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

  def then_i_see_the_error_message_for_date_not_chosen
    expect(withdrawal_date_page).to have_content("Choose a withdrawal date")
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
    expect(page).to have_css(".govuk-error-message", text: /Choose a reason for the trainee’s decision to withdraw/)
  end

  def then_i_see_the_error_message_for_trigger_not_chosen
    expect(withdrawal_trigger_page).to have_content("Please select an option")
  end

  def then_i_see_the_error_message_for_future_interest_not_chosen
    expect(withdrawal_future_interest_page).to have_content("Please select an option")
  end

  def then_i_see_the_error_message_for_unknown_exclusivity
    expect(withdrawal_reason_page).to have_content('Only select "Unknown" if no other withdrawal reasons apply')
  end

  def and_i_see_the_summary_card(withdrawal_date:, reason:)
    expect(page).to have_text(date_for_summary_view(withdrawal_date))
    expect(page).to have_text(I18n.t("components.withdrawal_details.reasons.#{reason}"))
  end

  def and_i_can_see_the_safeguarding_concern_reasons_text
    expect(page).to have_text("Some details about safeguarding concerns")
  end

  def then_the_withdrawal_details_is_updated
    trainee.reload
    expect(withdrawal_page).to have_text(date_for_summary_view(trainee.withdraw_date))
  end

  def then_i_am_redirected_to_withdrawal_confirmation_page
    expect(withdrawal_confirm_detail_page).to be_displayed(id: trainee.slug)
  end

  def then_the_withdraw_date_and_reason_is_updated
    trainee.reload
    expect(withdrawal_page).to have_text(trainee.withdraw_date.strftime("%-d %B %Y"))
  end

  def given_a_trainee_exists_to_be_withdrawn
    given_a_trainee_exists(
      %i[submitted_for_trn trn_received].sample,
      trainee_start_date: 10.days.ago,
      itt_end_date: 1.year.from_now,
    )
  end

  def given_a_trainee_exists_to_be_withdrawn_with_no_start_date
    given_a_trainee_exists(
      %i[submitted_for_trn trn_received].sample,
      trainee_start_date: nil,
      itt_end_date: 1.year.from_now,
    )
  end

  def given_a_deferred_trainee_exists
    given_a_trainee_exists(:deferred)
  end

  def given_a_trainee_exists_that_is_already_withdrawn
    @trainee ||= create(:trainee, :withdrawn)
  end

  def and_the_trainee_has_a_duplicate
    @trainee.dup.tap { |t| t.slug = t.generate_slug }.save
  end

  def when_i_cancel_my_changes(page)
    public_send("withdrawal_#{page}_page").cancel.click
  end

  def then_i_am_redirected_to_the_record_page
    expect(record_page).to be_displayed(id: trainee.slug)
  end

  def and_the_withdrawal_information_i_set_is_cleared
    trainee.reload
    expect(trainee.withdraw_date).to be_nil
    expect(trainee.withdrawal_reasons).to be_empty
  end

  def then_the_deferral_text_should_be_shown
    expect(withdrawal_reason_page).to have_deferral_notice
  end

  def then_the_duplicate_record_text_should_be_shown
    expect(withdrawal_date_page).to have_duplicate_notice
  end

  def and_the_deferral_date_is_used
    expect(page).to have_text(date_for_summary_view(trainee.defer_date))
  end

  def and_i_choose_they_have_started
    start_date_verification_page.started_option.choose
    start_date_verification_page.continue.click
  end

  def when_i_choose_they_started_on_time
    trainee_start_status_edit_page.commencement_status_started_on_time.choose
    trainee_start_status_edit_page.continue.click
  end

  def then_i_should_be_on_the_withdrawal_page
    expect(withdrawal_date_page).to be_displayed
  end

  def and_i_choose_they_have_not_started
    start_date_verification_page.not_started_option.choose
    start_date_verification_page.continue.click
  end

  def then_i_am_taken_to_the_forbidden_withdrawal_page
    expect(withdrawal_forbidden_page).to be_displayed
  end

  def and_i_click_change_start_date
    withdrawal_confirm_detail_page.start_date_change_link.click
  end

  def then_i_am_redirected_to_start_date_verification_page
    expect(start_date_verification_page).to be_displayed(id: trainee.slug)
  end

  def then_i_cannot_see_the_withdraw_link
    expect(record_page).not_to have_text(t("views.trainees.edit.withdraw"))
  end

  def then_i_cannot_see_the_edit_withdrawal_link
    expect(record_page).not_to have_change_trainee_status
  end

  def then_i_can_see_the_edit_withdrawal_details_component
    expect(record_page).to have_withdrawal_details_component
  end

  def and_i_select_no_they_started_later
    trainee_start_status_edit_page.commencement_status_started_later.choose
  end

  def and_i_fill_in_a_new_start_date(date)
    trainee_start_status_edit_page.set_date_fields("trainee_start_date", date.strftime("%d/%m/%Y"))
  end

  def and_integrate_with_dqt_feature_is_active
    enable_features(:integrate_with_dqt)
  end

  def and_a_withdrawal_job_has_been_queued
    expect(Dqt::WithdrawTraineeJob).to have_been_enqueued
  end
end
