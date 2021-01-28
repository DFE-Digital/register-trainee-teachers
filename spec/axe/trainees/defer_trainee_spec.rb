# frozen_string_literal: true

require "rails_helper_axe"

RSpec.feature "Deferring a trainee",  axe: true,
                                      driver: :selenium_headless do
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
      expect(page).to be_axe_clean
    end
  end

  def and_i_am_on_the_trainee_record_page
    record_page.load(id: trainee.slug)
  end

  def and_i_click_on_defer
    record_page.defer.click
  end

  def and_i_continue
    deferral_page.continue.click
  end

  def then_i_see_the_error_message_for_date_not_chosen
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.deferral_form.attributes.defer_date_string.blank"),
    )
  end

  def given_a_trainee_exists_to_be_deferred
    given_a_trainee_exists(%i[submitted_for_trn trn_received].sample)
  end

  def record_page
    @record_page ||= PageObjects::Trainees::Record.new
  end

  def deferral_page
    @deferral_page ||= PageObjects::Trainees::Deferral.new
  end
end
