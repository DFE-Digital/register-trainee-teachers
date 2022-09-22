# frozen_string_literal: true

require "rails_helper"

feature "Deleting a user" do
  let(:system_admin) { create(:user, system_admin: true) }
  let(:user) { create(:user) }

  before do
    given_i_am_authenticated(user: system_admin)
  end

  scenario "can be done by an admin" do
    visiting_the_users_page
    and_i_click_on_delete
    i_am_taken_to_the_delete_user_page
    where_i_click_the_delete_button
    and_successfully_delete_the_user
  end

  context "that is a system admin" do
    before { user.update!(system_admin: true) }

    it "does not allow the user to be deleted" do
      visiting_the_users_page
      there_is_no_delete_link
      delete_page_is_redirected
    end
  end

private

  def visiting_the_users_page
    admin_show_user_page.load(id: user.id)
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

  def there_is_no_delete_link
    expect(admin_show_user_page).to have_no_delete_user
  end

  def delete_page_is_redirected
    admin_delete_user_page.load(id: user.id)
    expect(admin_index_user_page).to be_displayed
  end
end
