# frozen_string_literal: true

require "rails_helper"

feature "TrainingPartnerSearch" do
  before do
    given_i_am_authenticated
    given_a_provider_led_postgrad_trainee_exists
    and_a_number_of_training_partners_exist
    and_i_visit_the_trainee_edit_training_partner_page
  end

  scenario "choosing a training partner", js: true do
    and_i_fill_in_my_training_partner
    and_i_click_the_first_item_in_the_list
    and_i_continue
    then_i_am_redirected_to_the_confirm_training_partner_page
  end

  scenario "searching for a training partner by postcode", js: true do
    and_i_fill_in_my_training_partner_postcode
    and_i_click_the_first_item_in_the_list
    and_i_continue
    then_i_am_redirected_to_the_confirm_training_partner_page
  end

  scenario "choosing a training partner without javascript" do
    and_i_fill_in_my_training_partner_without_js
    and_i_continue
    then_i_am_redirected_to_the_training_partners_page_filtered_by_my_query
  end

  scenario "when a training partner is not selected", js: true do
    and_i_fill_in_my_training_partner
    and_i_continue
    then_i_am_redirected_to_the_training_partners_page_filtered_by_my_query
  end

private

  def given_a_provider_led_postgrad_trainee_exists
    given_a_trainee_exists(:school_direct_tuition_fee)
  end

  def and_i_fill_in_my_training_partner
    edit_training_partner_page.training_partner.fill_in with: my_training_partner_name
  end

  def and_i_fill_in_my_training_partner_postcode
    edit_training_partner_page.training_partner.fill_in with: my_training_partner_postcode
  end

  def and_i_fill_in_my_training_partner_without_js
    edit_training_partner_page.training_partner_no_js.fill_in with: my_training_partner_name
  end

  def and_i_click_the_first_item_in_the_list
    click(edit_training_partner_page.autocomplete_list_item)
  end

  def and_i_continue
    click(edit_training_partner_page.submit)
  end

  def and_a_number_of_training_partners_exist
    @training_partners = create_list(:training_partner, 5, :school)
  end

  def and_i_visit_the_trainee_edit_training_partner_page
    edit_training_partner_page.load(trainee_id: trainee.slug)
  end

  def my_training_partner_name
    my_training_partner.name.split.first
  end

  def my_training_partner_postcode
    my_training_partner.school&.postcode
  end

  def my_training_partner
    @my_training_partner ||= @training_partners.sample
  end

  def then_i_am_redirected_to_the_confirm_training_partner_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_training_partners_page_filtered_by_my_query
    expect(training_partners_search_page).to be_displayed(trainee_id: trainee.slug, query: my_training_partner_name)
  end
end
