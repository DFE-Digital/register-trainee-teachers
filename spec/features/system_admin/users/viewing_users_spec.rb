# frozen_string_literal: true

require "rails_helper"

feature "View users" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }

    before do
      provider.users = [user]
      given_i_am_authenticated(user:)
      and_a_provider_exists
      when_i_visit_the_provider_index_page
      and_i_click_on_a_provider
      then_i_am_taken_to_the_provider_show_page
    end

    scenario "I can view the users" do
      then_i_see_the_users
    end
  end

  def when_i_visit_the_provider_index_page
    providers_index_page.load
  end

  def and_a_provider_exists
    provider
  end

  def and_i_click_on_a_provider
    providers_index_page.provider_cards.find { |card| card.name.text == provider.name_and_code }.name.click
  end

  def then_i_am_taken_to_the_provider_show_page
    expect(provider_show_page).to be_displayed(id: provider.id)
  end

  def then_i_see_the_users
    expect(provider_show_page.user_cards.size).to eq(1)
  end

  def provider
    @provider ||= create(:provider)
  end
end
