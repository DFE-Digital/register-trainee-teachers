# frozen_string_literal: true

require "rails_helper"

feature "Creating a new user" do
  let(:user) { create(:user, system_admin: true) }
  let(:dttp_id) { SecureRandom.uuid }

  before do
    given_i_am_authenticated(user:)
    when_i_visit_the_user_index_page
    and_i_click_on_add_a_user
  end

  describe "Adding a user" do
    context "Valid details" do
      scenario "Adding a new user record without organisation association" do
        and_i_fill_in_first_name
        and_i_fill_in_last_name
        and_i_fill_in_email
        and_i_fill_in_dttp_id
        when_i_save_the_form
        then_i_am_taken_to_the_user_show_page
      end
    end

    context "Invalid details" do
      scenario "Failing to add a user trigging the validations" do
        when_i_save_the_form
        then_i_should_see_the_error_summary
      end

      scenario "Failing to add a user with first name exceeding the character limit" do
        and_i_fill_in_first_name_with_too_many_characters
        when_i_save_the_form
        then_i_should_see_the_error_summary
      end

      scenario "Failing to add a user with last name exceeding the character limit" do
        and_i_fill_in_last_name_with_too_many_characters
        when_i_save_the_form
        then_i_should_see_the_error_summary
      end

      scenario "Failing to add a user with email exceeding the character limit" do
        and_i_fill_in_email_with_too_many_characters
        when_i_save_the_form
        then_i_should_see_the_error_summary
      end
    end
  end

private

  def when_i_visit_the_user_index_page
    admin_users_index_page.load
  end

  def then_i_am_taken_to_the_user_show_page
    expect(admin_user_show_page).to have_text(I18n.t("system_admin.users.create.success"))
  end

  def and_i_click_on_add_a_user
    admin_users_index_page.add_a_user.click
  end

  def and_i_fill_in_first_name
    admin_new_user_page.first_name.set("Darth")
  end

  def and_i_fill_in_last_name
    admin_new_user_page.last_name.set("Vader")
  end

  def and_i_fill_in_email
    admin_new_user_page.email.set("darthvader@email.com")
  end

  def and_i_fill_in_dttp_id
    admin_new_user_page.dttp_id.set(dttp_id)
  end

  def and_i_fill_in_first_name_with_too_many_characters
    admin_new_user_page.first_name.set("A" * 256)
  end

  def and_i_fill_in_last_name_with_too_many_characters
    admin_new_user_page.last_name.set("A" * 256)
  end

  def and_i_fill_in_email_with_too_many_characters
    admin_new_user_page.email.set("A" * 256)
  end

  def when_i_save_the_form
    admin_new_user_page.submit.click
  end

  def then_i_should_see_the_error_summary
    expect(admin_new_user_page.error_summary).to be_visible
  end
end
