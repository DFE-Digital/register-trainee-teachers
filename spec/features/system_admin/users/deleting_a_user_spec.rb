# frozen_string_literal: true

require "rails_helper"

feature "Delete a provider user" do
  let(:provider) { create(:provider) }
  let(:user) { create(:user, providers: [provider]) }
  let(:system_admin) { create(:user, system_admin: true) }

  before do
    given_i_am_authenticated(user: system_admin)
    given_a_user_is_associated_with_the_provider
    when_i_visit_the_providers_index_page
    and_i_click_on_the_provider
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

  def given_a_user_is_associated_with_the_provider
    user
  end

  def when_i_visit_the_providers_index_page
    providers_index_page.load
  end

  def and_i_click_on_the_provider
    providers_index_page.provider_cards.find { |provider_card| provider_card.name.text == provider.name }.name.click
  end

  def then_i_am_taken_to_the_provider_show_page
    provider_show_page.load(id: provider.id)
  end

  def and_i_see_the_registered_users
    expect(provider_show_page.registered_user_cards.size).to eq(1)
  end

  def when_i_click_delete_user
    provider_show_page.registered_user_cards.first.delete_user_button.click
  end

  def i_am_taken_to_the_user_delete_page
    user_delete_page.load(provider_id: provider.id, id: user.id)
  end

  def and_i_click_that_im_sure_i_want_to_delete_a_user
    user_delete_page.delete_a_user.click
  end

  def then_i_am_redirected_to_the_provider_show_page
    provider_show_page.load(id: provider.id)
  end

  def and_the_user_has_been_deleted
    expect(provider_show_page.registered_user_cards.size).to eq(0)
  end
end
