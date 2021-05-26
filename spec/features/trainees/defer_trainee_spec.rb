# frozen_string_literal: true

require "rails_helper"

feature "Deferring a trainee", type: :feature do
  include SummaryHelper

  before do
    given_i_am_authenticated
    given_a_trainee_exists_to_be_deferred
    and_i_am_on_the_trainee_record_page
    and_i_click_on_defer
  end

  context "trainee deferral date" do
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

    scenario "choosing yesterday" do
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

  scenario "cancelling changes" do
    when_i_choose_today
    and_i_continue
    then_i_am_redirected_to_deferral_confirmation_page
    and_i_see_my_date(Time.zone.today)
    when_i_cancel_my_changes
    then_i_am_redirected_to_the_record_page
    and_the_defer_date_i_chose_is_cleared
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
    @chosen_date = Faker::Date.in_date_period
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
    when_i_choose("On another day")
  end

  def and_i_continue
    deferral_page.continue.click
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

  def given_a_trainee_exists_to_be_deferred
    given_a_trainee_exists(%i[submitted_for_trn trn_received].sample)
  end

  def then_the_defer_date_is_updated
    expect(deferral_confirmation_page).to have_text(date_for_summary_view(trainee.reload.defer_date))
  end

  def when_i_cancel_my_changes
    deferral_confirmation_page.cancel.click
  end

  def then_i_am_redirected_to_the_record_page
    expect(record_page).to be_displayed(id: trainee.slug)
  end

  def and_the_defer_date_i_chose_is_cleared
    expect(trainee.defer_date).to be_nil
  end
end
