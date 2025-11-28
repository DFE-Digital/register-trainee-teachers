# frozen_string_literal: true

require "rails_helper"

feature "TrainingPartnerSearch" do
  before do
    given_i_am_authenticated
    given_a_provider_led_postgrad_trainee_exists
    and_a_number_of_lead_partners_exist
    and_i_visit_the_trainee_edit_lead_partner_page
  end

  scenario "choosing a lead partner", js: true do
    and_i_fill_in_my_lead_partner
    and_i_click_the_first_item_in_the_list
    and_i_continue
    then_i_am_redirected_to_the_confirm_lead_partner_page
  end

  scenario "searching for a lead partner by postcode", js: true do
    and_i_fill_in_my_lead_partner_postcode
    and_i_click_the_first_item_in_the_list
    and_i_continue
    then_i_am_redirected_to_the_confirm_lead_partner_page
  end

  scenario "choosing a lead partner without javascript" do
    and_i_fill_in_my_lead_partner_without_js
    and_i_continue
    then_i_am_redirected_to_the_lead_partners_page_filtered_by_my_query
  end

  scenario "when a lead partner is not selected", js: true do
    and_i_fill_in_my_lead_partner
    and_i_continue
    then_i_am_redirected_to_the_lead_partners_page_filtered_by_my_query
  end

private

  def given_a_provider_led_postgrad_trainee_exists
    given_a_trainee_exists(:school_direct_tuition_fee)
  end

  def and_i_fill_in_my_lead_partner
    edit_lead_partner_page.lead_partner.fill_in with: my_lead_partner_name
  end

  def and_i_fill_in_my_lead_partner_postcode
    edit_lead_partner_page.lead_partner.fill_in with: my_lead_partner_postcode
  end

  def and_i_fill_in_my_lead_partner_without_js
    edit_lead_partner_page.lead_partner_no_js.fill_in with: my_lead_partner_name
  end

  def and_i_click_the_first_item_in_the_list
    click(edit_lead_partner_page.autocomplete_list_item)
  end

  def and_i_continue
    click(edit_lead_partner_page.submit)
  end

  def and_a_number_of_lead_partners_exist
    @lead_partners = create_list(:lead_partner, 5, :school)
  end

  def and_i_visit_the_trainee_edit_lead_partner_page
    edit_lead_partner_page.load(trainee_id: trainee.slug)
  end

  def my_lead_partner_name
    my_lead_partner.name.split.first
  end

  def my_lead_partner_postcode
    my_lead_partner.school&.postcode
  end

  def my_lead_partner
    @my_lead_partner ||= @lead_partners.sample
  end

  def then_i_am_redirected_to_the_confirm_lead_partner_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_lead_partners_page_filtered_by_my_query
    expect(lead_partners_search_page).to be_displayed(trainee_id: trainee.slug, query: my_lead_partner_name)
  end
end
