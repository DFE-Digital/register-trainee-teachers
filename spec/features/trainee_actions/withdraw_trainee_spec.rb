# frozen_string_literal: true

require "rails_helper"

feature "Withdrawing a trainee" do
  include SummaryHelper

  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
  end

  after do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
  end

  let!(:withdrawal_reason) { create(:withdrawal_reason) }
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

    scenario "reason given with 'unknown' also selected" do
      when_i_am_on_the_reason_page
      when_i_check_a_reason(withdrawal_reason_unknown.name)
      when_i_check_a_reason(withdrawal_reason.name)
      and_i_continue(:reason)
      then_i_see_the_error_message_for_reason_not_chosen
    end

    scenario "extra details too long" do
      when_i_am_on_the_extra_information_page
      when_i_add_detail(:withdraw_reasons_details, Faker::Lorem.words(number: 200).join(" "))
      and_i_continue(:extra_information)
      then_i_see_the_error_message_for_details_too_long
    end

    scenario "extra details dfe too long" do
      when_i_am_on_the_extra_information_page
      when_i_add_detail(:withdraw_reasons_dfe_details, Faker::Lorem.words(number: 200).join(" "))
      and_i_continue(:extra_information)
      then_i_see_the_error_message_for_dfe_details_too_long
    end
  end

  context "trainee withdrawn" do
    before do
      when_i_am_on_the_withdrawal_page
    end

    let(:details) { Faker::Lorem.words(number: 20).join(" ") }
    let(:details_dfe) { Faker::Lorem.words(number: 20).join(" ") }
    let(:withdrawal_date) { Time.zone.today }
    let(:reason) { withdrawal_reason.name }
    let(:start_date) { trainee.trainee_start_date }

    scenario "today" do
      when_i_choose_today
      and_i_continue(:date)
      when_i_check_a_reason(withdrawal_reason.name)
      and_i_continue(:reason)
      when_i_add_detail(:withdraw_reasons_details, details)
      when_i_add_detail(:withdraw_reasons_dfe_details, details_dfe)
      and_i_continue(:extra_information)
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_i_see_the_summary_card(start_date:, withdrawal_date:, details:, details_dfe:, reason:)
      and_i_continue(:confirm_detail)
      then_i_am_redirected_to_the_record_page
      and_i_see_the_summary_card(start_date:, withdrawal_date:, details:, details_dfe:, reason:)
    end

    scenario "yesterday" do
      let(:withdrawal_date) { Time.zone.yesterday }

      when_i_choose_yesterday
      and_i_continue(:date)
      when_i_check_a_reason(withdrawal_reason.name)
      and_i_continue(:reason)
      when_i_add_detail(:withdraw_reasons_details, details)
      when_i_add_detail(:withdraw_reasons_dfe_details, details_dfe)
      and_i_continue(:extra_information)
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_i_see_the_summary_card(start_date:, withdrawal_date:, details:, details_dfe:, reason:)
      and_i_continue(:confirm_detail)
      then_i_am_redirected_to_the_record_page
      and_i_see_the_summary_card(start_date:, withdrawal_date:, details:, details_dfe:, reason:)
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

    scenario "when DQT integration feature is active" do
      when_i_choose_today
      and_integrate_with_dqt_feature_is_active
      and_i_continue
      then_i_am_redirected_to_withdrawal_confirmation_page
      and_i_see_my_date(Time.zone.today)
      when_i_withdraw
      then_the_withdraw_date_and_reason_is_updated
      and_a_withdrawal_job_has_been_queued
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

  scenario "trainee has not started course" do
    given_i_am_authenticated
    given_a_trainee_exists_to_be_withdrawn_with_no_start_date
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw
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

  scenario "when the trainee is a duplicate" do
    given_i_am_authenticated
    given_a_trainee_exists_to_be_withdrawn
    and_the_trainee_has_a_duplicate
    and_i_am_on_the_trainee_record_page
    and_i_click_on_withdraw
    then_the_duplicate_record_text_should_be_shown
  end

  scenario "trainee is withdrawn and changes their start date to a date before the withdrawal date" do
    when_i_am_on_the_withdrawal_page
    and_i_choose_today
    and_i_choose_a_specific_reason
    and_i_continue
    then_i_am_redirected_to_withdrawal_confirmation_page
    and_i_click_change_start_date
    and_i_choose_they_have_started
    and_i_continue
    and_i_select_no_they_started_later
    and_i_fill_in_a_new_start_date(2.days.ago)
    and_i_continue
    then_i_am_redirected_to_withdrawal_confirmation_page
    and_i_see_my_date(2.days.ago)
  end

  scenario "trainee is withdrawn and changes their start date to a date after the withdrawal date" do
    when_i_am_on_the_withdrawal_page
    when_i_choose_yesterday
    and_i_choose_a_specific_reason
    and_i_continue
    then_i_am_redirected_to_withdrawal_confirmation_page
    and_i_click_change_start_date
    and_i_choose_they_have_started
    and_i_continue
    and_i_select_no_they_started_later
    and_i_fill_in_a_new_start_date(Time.zone.today)
    and_i_continue
    then_i_should_be_on_the_withdrawal_page
    and_i_choose_today
    and_i_choose_a_specific_reason
    and_i_continue
    then_i_am_redirected_to_withdrawal_confirmation_page
    and_i_see_my_date(Time.zone.today)
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
    and_i_click_on_withdraw
  end


  def when_i_am_on_the_date_page
    withdrawal_date_page.load(id: trainee.slug)
  end

  def when_i_am_on_the_reason_page
    withdrawal_reason_page.load(id: trainee.slug)
  end

  def when_i_am_on_the_extra_information_page
    withdrawal_extra_information_page.load(id: trainee.slug)
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

  def and_i_enter_a_valid_date
    @chosen_date = valid_date_after_itt_start_date
    @chosen_date.tap do |withdraw_date|
      withdrawal_page.set_date_fields(:withdraw_date, withdraw_date.strftime("%d/%m/%Y"))
    end
  end

  def when_i_add_detail(input, words)
    withdrawal_extra_information_page.send(input).fill_in(with: words)
  end

  def when_i_check_a_reason(reason)
    when_i_check(:reason, I18n.t("components.withdrawal_details.reasons.#{reason}"))
  end

  def when_i_choose(page, option)
    send("withdrawal_#{page}_page").choose(option)
  end

  def when_i_check(page, option)
    send("withdrawal_#{page}_page").check(option)
  end

  def and_i_continue(page)
    send("withdrawal_#{page}_page").continue.click
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
    expect(withdrawal_reason_page).to have_content('Select why the trainee withdrew from the course or select "Unknown"')
  end

  def then_i_see_the_error_message_for_details_too_long
    expect(withdrawal_reason_page).to have_content("Details about why the trainee withdrew must be 500 characters or less")
  end

  def then_i_see_the_error_message_for_dfe_details_too_long
    expect(withdrawal_reason_page).to have_content("What the Department for Education could have done must be x characters or less")
  end

  def then_i_see_the_error_message_for_missing_additional_reason
    expect(withdrawal_page).to have_content(
      I18n.t("activemodel.errors.models.withdrawal_form.attributes.additional_withdraw_reason.blank"),
    )
  end

  def and_i_see_the_summary_card(start_date:, withdrawal_date:, details:, details_dfe:, reason:)
    expect(page).to have_text(date_for_summary_view(start_date))
    expect(page).to have_text(date_for_summary_view(withdrawal_date))
    expect(page).to have_text(details)
    expect(page).to have_text(details_dfe)
    expect(page).to have_text(I18n.t("components.withdrawal_details.reasons.#{reason}"))
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

  def and_the_additional_reason_is_displayed
    trainee.reload
    expect(withdrawal_confirmation_page).to have_text(additional_withdraw_reason)
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

  def then_the_duplicate_record_text_should_be_shown
    expect(withdrawal_page).to have_duplicate_notice
  end

  def and_the_deferral_date_is_used
    expect(withdrawal_confirmation_page).to have_text(
      t("components.withdrawal_details.withdrawal_date", date: date_for_summary_view(trainee.defer_date)),
    )
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
    expect(withdrawal_page).to be_displayed
  end

  def and_i_choose_they_have_not_started
    start_date_verification_page.not_started_option.choose
    start_date_verification_page.continue.click
  end

  def then_i_am_taken_to_the_forbidden_withdrawal_page
    expect(withdrawal_forbidden_page).to be_displayed
  end

  def and_i_click_change_start_date
    withdrawal_confirmation_page.start_date_change_link.click
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
