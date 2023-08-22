# frozen_string_literal: true

require "rails_helper"

feature "edit contact details" do
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

private

  def and_i_am_on_the_contact_details_page
    contact_details_page.load(id: trainee.slug)
  end

  def and_i_make_a_change
    @new_email_address = Faker::Internet.email

    contact_details_page.email.set(@new_email_address)
  end

  def and_i_submit_the_form
    contact_details_page.submit_button.click
  end

  def and_the_contact_details_are_updated
    expect(contact_details_page.email.value).to eq(@new_email_address)
  end
end
