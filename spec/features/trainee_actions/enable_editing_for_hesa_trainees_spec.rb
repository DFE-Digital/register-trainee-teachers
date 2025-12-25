# frozen_string_literal: true

require "rails_helper"

feature "Allow HEIs to enable editing of individual HESA records" do
  background do
    given_i_am_authenticated
  end

  scenario "enable editing" do
    given_a_hesa_trainee_exists
    and_i_am_on_the_trainee_page
    and_i_cannot_change_trainee_data
    when_i_click_the_enable_editing_button
    then_i_should_see_editing_enabled_page
    and_i_return_to_trainee_page
    then_i_should_see_the_change_links
  end

  scenario "interstitial defer page" do
    given_a_hesa_trainee_exists
    and_i_am_on_the_trainee_page
    when_i_click_on_defer
    then_i_see_an_interstitial_defer_page
    when_i_click_continue_to_defer
    then_i_should_see_the_defer_page
  end

  scenario "interstitial reinstate page" do
    given_a_deferred_hesa_trainee_exists
    and_i_am_on_the_trainee_page
    when_i_click_on_reinstate
    then_i_see_an_interstitial_reinstate_page
    when_i_click_continue_to_reinstate
    then_i_should_see_the_reinstatement_page
  end

private

  def given_a_hesa_trainee_exists
    given_a_trainee_exists(:trn_received, :imported_from_hesa)
  end

  def given_a_deferred_hesa_trainee_exists
    given_a_trainee_exists(:deferred, :imported_from_hesa)
  end

  def and_i_am_on_the_trainee_page
    record_page.load(id: @trainee.slug)
  end

  def and_i_cannot_change_trainee_data
    expect(record_page).not_to have_content("You can now make changes to this trainee")
  end

  def when_i_click_the_enable_editing_button
    record_page.enable_editing.click
  end

  def then_i_should_see_editing_enabled_page
    expect(hesa_editing_enabled_page).to be_displayed
  end

  def and_i_return_to_trainee_page
    hesa_editing_enabled_page.return.click
  end

  def then_i_should_see_the_change_links
    expect(record_page).not_to have_content("You can now make changes to this trainee")
  end

  def when_i_click_on_defer
    record_page.defer.click
  end

  def when_i_click_on_reinstate
    record_page.reinstate.click
  end

  def then_i_see_an_interstitial_defer_page
    expect(interstitials_hesa_defer_page).to be_displayed
  end

  def then_i_see_an_interstitial_reinstate_page
    expect(interstitials_hesa_reinstate_page).to be_displayed
  end

  def when_i_click_continue_to_defer
    interstitials_hesa_defer_page.continue.click
  end

  def when_i_click_continue_to_reinstate
    interstitials_hesa_reinstate_page.continue.click
  end

  def then_i_should_see_the_defer_page
    expect(deferral_page).to be_displayed
  end

  def then_i_should_see_the_reinstatement_page
    expect(reinstatement_page).to be_displayed
  end
end
