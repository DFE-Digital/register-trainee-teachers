# frozen_string_literal: true

require "rails_helper"

feature "Deleting a user" do
  let(:system_admin) { create(:user, system_admin: true) }
  let(:user) { create(:user) }

  before do
    given_i_am_authenticated(user: system_admin)
    visiting_the_users_page(user.id)
  end

  scenario "Allows the admin to delete a user" do
    and_i_click_on_delete
    i_am_taken_to_the_delete_user_page
    where_i_click_the_delete_button
    and_successfully_delete_the_user
  end

private

  def visiting_the_users_page(id)
    admin_show_user_page.load(id: id)
  end

  def and_i_click_on_delete
    admin_show_user_page.delete_user.click
  end

  def i_am_taken_to_the_delete_user_page
    expect(admin_delete_user_page).to be_displayed(id: user.id)
  end

  def where_i_click_the_delete_button
    admin_delete_user_page.delete_button.click
  end

  def and_successfully_delete_the_user
    expect(admin_index_user_page.flash_message).to be_visible
    expect(user.reload.discarded?).to be true
  end
end
