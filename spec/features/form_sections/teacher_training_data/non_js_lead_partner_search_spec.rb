# frozen_string_literal: true

require "rails_helper"

feature "Non-JS lead partner search" do
  let!(:discarded_lead_partner) { create(:lead_partner, :lead_school, :discarded) }

  before do
    given_i_am_authenticated
    given_a_school_direct_tuition_fee_trainee_exists
    and_a_number_of_lead_partners_exists
    and_i_am_on_the_lead_partners_page_filtered_by_my_query
  end

  scenario "choosing a lead partner" do
    and_i_choose_my_lead_partner
    and_i_continue
    then_i_am_redirected_to_the_confirm_lead_partner_page
  end

  scenario "choosing search again option" do
    and_i_choose_the_search_option
    and_i_enter_a_search_term_that_should_yield_no_results
    and_i_continue
    then_i_should_see_no_results
    and_i_should_see_a_search_again_field
  end

private

  def given_a_school_direct_tuition_fee_trainee_exists
    given_a_trainee_exists(:school_direct_tuition_fee)
  end

  def and_i_choose_my_lead_partner
    lead_partners_search_page.choose_lead_partner(id: my_lead_partner.id)
  end

  def and_i_choose_the_search_option
    lead_partners_search_page.search_again_option.choose
  end

  def and_i_enter_a_search_term_that_should_yield_no_results
    lead_partners_search_page.results_search_again_input.set(discarded_lead_partner.name)
  end

  def then_i_should_see_no_results
    expect(lead_partners_search_page).to have_text("#{t('components.page_titles.search_schools.sub_text_no_results')} #{discarded_lead_partner.name}")
  end

  def and_i_should_see_a_search_again_field
    expect(lead_partners_search_page).to have_zero_results_search_again_input
  end

  def and_i_continue
    lead_partners_search_page.continue.click
  end

  def and_a_number_of_lead_partners_exists
    @lead_partners = create_list(:lead_partner, 5, :lead_school)
  end

  def and_i_am_on_the_lead_partners_page_filtered_by_my_query
    lead_partners_search_page.load(trainee_id: trainee.slug, query: query)
  end

  def then_i_am_redirected_to_the_confirm_lead_partner_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end

  def query
    my_lead_partner.name.split.first
  end

  def my_lead_partner
    @my_lead_partner ||= @lead_partners.sample
  end
end
