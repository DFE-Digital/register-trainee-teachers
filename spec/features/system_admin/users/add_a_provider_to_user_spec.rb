# frozen_string_literal: true

require "rails_helper"

feature "creating a new user" do
  let(:user) { create(:user, system_admin: true) }
  let(:dttp_id) { SecureRandom.uuid }
  let!(:user_to_be_updated) { create(:user, first_name: "James", last_name: "Rodney") }
  let!(:new_provider) { create(:provider, name: "Richards Provider Supreme") }

  before do
    given_i_am_authenticated(user: user)
    when_i_visit_the_user_index_page
    and_i_click_on_the_user_name_link
    then_i_am_taken_to_the_user_show_page
    and_i_click_on_add_provider
    then_i_am_taken_to_the_add_provider_to_user_page
  end

  describe "adding a provider to a user" do
    context "valid details" do
      scenario "adding a new user record associated with a provider" do
        and_i_select_a_provider_from_the_dropdown
        and_i_click_submit
        then_i_am_taken_to_the_user_show_page
        and_i_see_the_new_provider
      end
    end
  end

private

  def when_i_visit_the_user_index_page
    admin_users_index_page.load
  end

  def and_i_click_on_the_user_name_link
    admin_users_index_page.users.find { |user| user.link.text == user_to_be_updated.name }.link.click
  end

  def then_i_am_taken_to_the_user_show_page
    expect(admin_user_show_page.current_path).to eq("/system-admin/users/#{user_to_be_updated.id}")
  end

  def and_i_click_on_add_provider
    admin_user_show_page.add_provider.click
  end

  def then_i_am_taken_to_the_add_provider_to_user_page
    expect(add_provider_to_user_page).to be_displayed(id: user_to_be_updated.id)
  end

  def and_i_select_a_provider_from_the_dropdown
    add_provider_to_user_page.provider_select.select("Richards Provider Supreme")
  end

  def and_i_click_submit
    add_provider_to_user_page.submit.click
  end

  def and_i_see_the_new_provider
    expect(admin_user_show_page.providers).to have_content(new_provider.name)
  end
end
