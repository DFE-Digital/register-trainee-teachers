# frozen_string_literal: true

require "rails_helper"

feature "Creating a new user" do
  let(:user) { create(:user, system_admin: true) }
  let(:dttp_id) { SecureRandom.uuid }

  before do
    given_i_am_authenticated(user: user)
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
    end
  end

private

  def when_i_visit_the_user_index_page
    users_index_page.load
  end

  def then_i_am_taken_to_the_user_show_page
    expect(users_show_page).to have_text(I18n.t("system_admin.users.create.success"))
  end

  def and_i_click_on_add_a_user
    users_index_page.add_a_user.click
  end

  def and_i_fill_in_first_name
    new_user_page.first_name.set("Darth")
  end

  def and_i_fill_in_last_name
    new_user_page.last_name.set("Vader")
  end

  def and_i_fill_in_email
    new_user_page.email.set("darthvader@email.com")
  end

  def and_i_fill_in_dttp_id
    new_user_page.dttp_id.set(dttp_id)
  end

  def when_i_save_the_form
    new_user_page.submit.click
  end

  def then_i_should_see_the_error_summary
    expect(new_user_page.error_summary).to be_visible
  end
end
