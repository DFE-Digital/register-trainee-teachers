# frozen_string_literal: true

require "rails_helper"

feature "Creating a new user" do
  let(:user) { create(:user, provider: system_admin.provider) }
  let(:system_admin) { create(:user, system_admin: true) }

  before do
    given_there_is_a_user(user)
    given_i_am_authenticated(user: system_admin)
    when_i_visit_the_provider_index_page
    and_i_click_on_a_provider
    then_i_am_taken_to_the_provider_show_page
    and_i_see_the_registered_users
  end

  scenario "I can delete a user" do
    when_i_click_delete_user
    i_am_taken_to_the_user_delete_page
    and_i_click_that_im_sure_i_want_to_delete_a_user
    then_i_am_redirected_to_the_provider_show_page
    and_the_user_has_been_deleted
  end

private

  def given_there_is_a_user(user)
    user
  end

  def when_i_visit_the_provider_index_page
    provider_index_page.load
  end

  def and_i_click_on_a_provider
    provider_index_page.provider_card.name.click
  end

  def then_i_am_taken_to_the_provider_show_page
    provider_show_page.load(id: system_admin.provider.id)
  end

  def and_i_see_the_registered_users
    expect(provider_show_page.registered_user_cards.size).to eq(2)
  end

  def when_i_click_delete_user
    provider_show_page.registered_user_cards.first.delete_user_button.click
  end

  def i_am_taken_to_the_user_delete_page
    user_delete_page.load(id: user.id)
  end

  def and_i_click_that_im_sure_i_want_to_delete_a_user
    user_delete_page.delete_a_user.click
  end

  def then_i_am_redirected_to_the_provider_show_page
    provider_show_page.load(id: system_admin.provider.id)
  end

  def and_the_user_has_been_deleted
    expect(provider_show_page.registered_user_cards.size).to eq(1)
  end

  def provider_show_page
    @provider_show_page ||= PageObjects::Providers::Show.new
  end

  def provider_index_page
    @provider_index_page ||= PageObjects::Providers::Index.new
  end

  def user_delete_page
    @user_delete_page ||= PageObjects::Users::Delete.new
  end
end
