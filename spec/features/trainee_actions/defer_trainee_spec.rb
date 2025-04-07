# frozen_string_literal: true

require "rails_helper"

feature "Deferring a trainee" do
  include SummaryHelper
  include ActionView::Helpers::SanitizeHelper

  background do
    given_i_am_authenticated
  end

  context "trainee deferral date" do
    before do
      given_a_trainee_exists_to_be_deferred
      given_i_initiate_a_deferral
    end

    scenario "submit empty form" do
      and_i_continue
      then_i_see_the_error_message_for_date_not_chosen
    end

    scenario "choosing today" do
      when_i_choose_today
      and_i_continue
      then_i_am_redirected_to_deferral_confirmation_page
      and_i_see_my_date(Time.zone.today)
      when_i_defer
      then_the_defer_date_is_updated
    end

    scenario "choosing yesterday", skip: skip_test_due_to_first_day_of_current_academic_year? do
      when_i_choose_yesterday
      and_i_continue
      then_i_am_redirected_to_deferral_confirmation_page
      and_i_see_my_date(Time.zone.yesterday)
      when_i_defer
      then_the_defer_date_is_updated
    end

    context "choosing another day" do
      before do
        when_i_choose_another_day
      end

      scenario "and filling out a valid date" do
        and_i_enter_a_valid_date
        and_i_continue
        then_i_am_redirected_to_deferral_confirmation_page
        and_i_see_my_date(@chosen_date)
        when_i_defer
        then_the_defer_date_is_updated
      end

      scenario "and not filling out the date displays the correct error" do
        and_i_continue
        then_i_see_the_error_message_for_blank_date
      end

      scenario "and filling out an invalid date displays the correct error" do
        deferral_page.set_date_fields("defer_date", "32/01/2020")
        and_i_continue
        then_i_see_the_error_message_for_invalid_date
      end
    end
  end

  scenario "itt start date is in the future" do
    given_a_trainee_with_course_starting_in_the_future_exists
    given_i_initiate_a_deferral
    then_i_am_redirected_to_deferral_confirmation_page
    and_i_see_a_message_for_trainee_deferred_before_itt_started
    when_i_defer
    then_the_trainee_is_deferred
  end

  describe "itt start date is in the past" do
    background do
      given_a_trainee_with_course_started_in_the_past_exists
      given_i_initiate_a_deferral
    end

    scenario "and the trainee did not start" do
      then_i_am_redirected_to_start_date_verification_page
      and_i_choose_they_have_not_started
      and_i_see_a_message_for_itt_started_but_trainee_deferred_before_starting
      when_i_defer
      then_the_trainee_is_deferred
    end

    scenario "and the trainee started" do
      then_i_am_redirected_to_start_date_verification_page
      and_i_choose_they_have_started
      then_i_am_redirected_to_trainee_start_status_page
      when_i_choose_they_started_on_time
      then_i_am_redirected_to_the_deferral_page
      when_i_choose_today
      and_i_continue
      then_i_am_redirected_to_deferral_confirmation_page
      and_i_see_my_date(Time.zone.today)
      and_i_see_my_itt_start_date
      when_i_defer
      then_the_trainee_is_deferred
    end
  end

  scenario "changing start date from deferral confirmation page" do
    given_a_trainee_exists_with_a_deferral_date
    given_i_am_on_the_deferral_confirmation_page
    and_i_click_on_the_change_link_for_start_date
    then_i_am_redirected_to_start_date_verification_page
    and_i_choose_they_have_started
    then_i_am_redirected_to_trainee_start_status_page
    when_i_choose_they_started_on_time
    then_i_am_redirected_to_deferral_confirmation_page
  end

  scenario "changing start date to be after the deferral date" do
    given_a_trainee_exists_with_a_deferral_date
    given_i_am_on_the_deferral_confirmation_page
    and_i_click_on_the_change_link_for_start_date
    then_i_am_redirected_to_start_date_verification_page
    and_i_choose_they_have_started
    then_i_am_redirected_to_trainee_start_status_page
    when_i_choose_the_trainee_has_started_later
    and_i_enter_a_start_date_after_the_deferral_date
    and_i_continue
    then_i_am_redirected_to_the_deferral_page
    when_i_choose_today
    and_i_continue
    then_i_am_redirected_to_deferral_confirmation_page
  end

  scenario "cancelling changes" do
    given_a_trainee_exists_to_be_deferred
    given_i_initiate_a_deferral
    when_i_choose_today
    and_i_continue
    then_i_am_redirected_to_deferral_confirmation_page
    and_i_see_my_date(Time.zone.today)
    when_i_cancel_my_changes
    then_i_am_redirected_to_the_record_page
    and_the_defer_date_i_chose_is_cleared
  end

  scenario "changing the deferral date" do
    given_a_trainee_exists_with_a_deferral_date
    and_i_am_on_the_trainee_record_page
    and_i_click_on_change_date_of_deferral
    when_i_choose_today
    and_i_continue
    then_i_am_redirected_to_deferral_confirmation_page
    and_i_see_my_date(Time.zone.today)
    when_i_defer
    then_the_defer_date_is_updated
    then_i_am_redirected_to_the_record_page
  end

  def given_i_initiate_a_deferral
    and_i_am_on_the_trainee_record_page
    and_i_click_on_defer
  end

  def and_i_click_on_change_date_of_deferral
    record_page.change_date_of_deferral.click
  end

  def given_i_am_on_the_deferral_confirmation_page
    deferral_confirmation_page.load(id: trainee.slug)
  end

  def and_i_click_on_the_change_link_for_start_date
    deferral_confirmation_page.start_date_change_link.click
  end

  def when_i_choose_today
    when_i_choose("Today")
  end

  def when_i_choose_yesterday
    when_i_choose("Yesterday")
  end

  def when_i_defer
    deferral_confirmation_page.defer.click
  end

  def and_i_enter_a_valid_date
    @chosen_date = valid_date_after_itt_start_date
    @chosen_date.tap do |defer_date|
      deferral_page.set_date_fields(:defer_date, defer_date.strftime("%d/%m/%Y"))
    end
  end

  def and_i_click_on_defer
    record_page.defer.click
  end

  def when_i_choose(option)
    deferral_page.choose(option)
  end

  def when_i_choose_another_day
    when_i_choose("Another date")
  end

  def and_i_continue
    deferral_page.continue.click
  end

  def and_i_see_a_message_for_trainee_deferred_before_itt_started
    expect(deferral_confirmation_page).to have_content(
      strip_tags(I18n.t("deferral_details.view.deferred_before_itt_started")),
    )
  end

  def and_i_see_a_message_for_itt_started_but_trainee_deferred_before_starting
    expect(deferral_confirmation_page).to have_content(
      strip_tags(I18n.t("deferral_details.view.itt_started_but_trainee_did_not_start")),
    )
  end

  def and_i_see_my_itt_start_date
    and_i_see_my_date(trainee.itt_start_date)
  end

  def then_i_see_the_error_message_for_invalid_date
    expect(deferral_page).to have_content(
      I18n.t("activemodel.errors.models.deferral_form.attributes.date.invalid"),
    )
  end

  def then_i_see_the_error_message_for_blank_date
    expect(deferral_page).to have_content(
      I18n.t("activemodel.errors.models.deferral_form.attributes.date.blank"),
    )
  end

  def then_i_see_the_error_message_for_date_not_chosen
    expect(deferral_page).to have_content(
      I18n.t("activemodel.errors.models.deferral_form.attributes.date_string.blank"),
    )
  end

  def then_i_am_redirected_to_deferral_confirmation_page
    expect(deferral_confirmation_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_start_date_verification_page
    expect(start_date_verification_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_trainee_start_status_page
    expect(trainee_start_status_edit_page).to be_displayed(trainee_id: trainee.slug)
  end

  def then_i_am_redirected_to_trainee_start_date_page
    expect(trainee_start_date_edit_page).to be_displayed(trainee_id: trainee.slug)
  end

  def when_i_choose_the_trainee_has_started_later
    trainee_start_status_edit_page.commencement_status_started_later.choose
  end

  def and_i_enter_a_start_date_after_the_deferral_date
    new_start_date = trainee.defer_date + 1.day
    trainee_start_status_edit_page.set_date_fields(:trainee_start_date, new_start_date.strftime("%d/%m/%Y"))
  end

  def given_a_trainee_exists_to_be_deferred
    given_a_trainee_exists(%i[submitted_for_trn trn_received].sample, :with_start_date)
  end

  def given_a_trainee_exists_with_a_deferral_date
    given_a_trainee_exists(:deferred,
                           trainee_start_date: 1.month.ago,
                           itt_start_date: 1.year.ago,
                           itt_end_date: 1.year.from_now,
                           defer_date: 1.week.ago)
  end

  def given_a_trainee_with_course_starting_in_the_future_exists
    given_a_trainee_exists(%i[submitted_for_trn trn_received].sample,
                           trainee_start_date: nil,
                           itt_start_date: Time.zone.today + 1.day)
  end

  def given_a_trainee_with_course_started_in_the_past_exists
    given_a_trainee_exists(%i[submitted_for_trn trn_received].sample,
                           trainee_start_date: nil,
                           itt_start_date: Time.zone.today - 1.day)
  end

  def and_i_choose_they_have_not_started
    start_date_verification_page.not_started_option.choose
    start_date_verification_page.continue.click
  end

  def and_i_choose_they_have_started
    start_date_verification_page.started_option.choose
    start_date_verification_page.continue.click
  end

  def when_i_choose_they_started_on_time
    trainee_start_status_edit_page.commencement_status_started_on_time.choose
    trainee_start_status_edit_page.continue.click
  end

  def then_the_defer_date_is_updated
    expect(deferral_confirmation_page).to have_text(date_for_summary_view(trainee.reload.defer_date))
  end

  def then_the_trainee_is_deferred
    expect(trainee.reload).to be_deferred
  end

  def when_i_cancel_my_changes
    deferral_confirmation_page.cancel.click
  end

  def then_i_am_redirected_to_the_record_page
    expect(record_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_deferral_page
    expect(deferral_page).to be_displayed(trainee_id: trainee.slug)
  end

  def and_the_defer_date_i_chose_is_cleared
    expect(trainee.defer_date).to be_nil
  end
end
