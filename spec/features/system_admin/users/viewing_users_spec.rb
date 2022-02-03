# frozen_string_literal: true

require "rails_helper"

feature "View users" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }

    before do
      given_i_am_authenticated(user: user)
      and_there_is_a_dttp_user
      and_a_provider_exists
      when_i_visit_the_provider_index_page
      and_i_click_on_a_provider
      then_i_am_taken_to_the_provider_show_page
    end

    scenario "I can view the users" do
      then_i_see_the_registered_users
    end

    scenario "I can view the DTTP users" do
      and_i_click_on_dttp_users_tab
      then_i_see_the_unregistered_users
    end

    scenario "I can register a dttp user to the provider" do
      and_i_click_on_dttp_users_tab
      when_i_register_the_dttp_user
      then_the_dttp_user_is_registered
    end
  end

  def when_i_visit_the_provider_index_page
    providers_index_page.load
  end

  def and_a_provider_exists
    provider
  end

  def and_there_is_a_dttp_user
    create(:dttp_user, provider_dttp_id: provider.dttp_id)
  end

  def and_i_click_on_a_provider
    providers_index_page.provider_cards.find { |card| card.name.text == provider.name }.name.click
  end

  def then_i_am_taken_to_the_provider_show_page
    expect(provider_show_page).to be_displayed(id: provider.id)
  end

  def then_i_see_the_registered_users
    expect(provider_show_page.registered_user_cards.size).to eq(1)
  end

  def then_i_see_the_unregistered_users
    expect(provider_dttp_users_index_page.unregistered_users.size).to eq(1)
  end

  def when_i_register_the_dttp_user
    provider_show_page.register_user.click
  end

  def and_i_click_on_dttp_users_tab
    provider_dttp_users_index_page.dttp_users_tab.click
  end

  def then_the_dttp_user_is_registered
    expect(provider_dttp_users_index_page).not_to have_unregistered_user_data
  end

  def provider
    @provider ||= create(:provider, dttp_id: SecureRandom.uuid, users: [build(:user)])
  end
end
