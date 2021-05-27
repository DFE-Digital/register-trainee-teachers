# frozen_string_literal: true

require "rails_helper"

feature "edit contact details", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
    and_i_am_on_the_contact_details_page
  end

  scenario "edit with valid parameters" do
    and_i_make_a_change
    and_i_submit_the_form
    and_i_am_on_the_contact_details_page
    and_the_contact_details_are_updated
  end

  scenario "changing locale clears previous address" do
    and_i_enter_an_international_address
    and_i_submit_the_form
    and_i_am_on_the_contact_details_page
    and_the_old_address_is_cleared
  end

private

  def and_i_am_on_the_contact_details_page
    contact_details_page.load(id: trainee.slug)
  end

  def and_i_make_a_change
    @new_address_line = Faker::Address.street_name

    contact_details_page.address_line_one.set(@new_address_line)
  end

  def and_i_submit_the_form
    contact_details_page.submit_button.click
  end

  def and_i_enter_an_international_address
    @new_address_line = Faker::Address.street_name

    contact_details_page.non_uk_locale.choose
    contact_details_page.international_address.set(@new_address_line)
  end

  def and_the_contact_details_are_updated
    expect(contact_details_page.address_line_one.value).to eq(@new_address_line)
  end

  def and_the_old_address_is_cleared
    expect(contact_details_page.international_address.value).to eq(@new_address_line)
    expect(contact_details_page.address_line_one.value).to be_nil
    expect(contact_details_page.address_line_two.value).to be_nil
    expect(contact_details_page.town_city.value).to be_nil
    expect(contact_details_page.postcode.value).to be_nil
  end
end
