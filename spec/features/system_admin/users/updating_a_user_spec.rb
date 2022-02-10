# frozen_string_literal: true

require "rails_helper"

feature "Creating a new user" do
  let(:system_admin) { create(:user, system_admin: true) }
  let(:user) { create(:user) }
  let(:dttp_id) { SecureRandom.uuid }

  before do
    given_i_am_authenticated(user: system_admin)
    when_i_visit_the_provider_show_page
    and_i_click_on_edit_user_link
    then_i_am_taken_to_the_edit_user_page
  end

  describe "Editing user details" do
    context "Valid details" do
      scenario "Editing a user record associated with a provider" do
        and_i_fill_in_email(email: "darthvader@email.com")
        when_i_save_the_form
        then_i_am_taken_to_the_provider_show_page
      end
    end

    context "Invalid details" do
      scenario "Failing to add a user trigging the validations" do
        and_i_fill_in_email(email: "darthvader email com")
        when_i_save_the_form
        then_i_should_see_the_error_summary
      end
    end
  end

private

  def when_i_visit_the_provider_show_page
    provider_show_page.load(id: provider.id)
  end

  def and_i_click_on_edit_user_link
    provider_show_page.edit_user_data.click
  end

  def then_i_am_taken_to_the_edit_user_page
    edit_user_page.load(provider_id: provider.id, id: user.id)
  end

  def and_i_click_on_add_a_user
    provider_show_page.add_a_user.click
  end

  def and_i_fill_in_email(email:)
    edit_user_page.email.set(email)
  end

  def when_i_save_the_form
    edit_user_page.submit.click
  end

  def then_i_should_see_the_error_summary
    expect(edit_user_page.error_summary).to be_visible
  end

  def then_i_am_taken_to_the_provider_show_page
    expect(provider_show_page).to be_displayed(id: provider.id)
  end

  def provider
    user.providers.first
  end
end
