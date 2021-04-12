# frozen_string_literal: true

require "rails_helper"

feature "View users" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let(:dttp_user) { create(:dttp_user, provider_id: user.provider.dttp_id) }

    before do
      dttp_user
      given_i_am_authenticated(user: user)
      when_i_visit_the_provider_index_page
      and_i_click_on_a_provider
      then_i_am_taken_to_the_provider_show_page
    end

    scenario "I can view the users" do
      then_i_see_the_users
      and_i_see_the_dttp_users_not_registered
    end
  end

  def when_i_visit_the_provider_index_page
    provider_index_page.load
  end

  def and_i_click_on_a_provider
    provider_index_page.provider_card.name.click
  end

  def then_i_am_taken_to_the_provider_show_page
    provider_show_page.load(id: user.provider.id)
  end

  def then_i_see_the_users
    expect(provider_show_page).to have_user_data
  end

  def and_i_see_the_dttp_users_not_registered
    expect(provider_show_page).to have_dttp_users_not_registered_data
  end

  def provider_show_page
    @provider_show_page ||= PageObjects::Providers::Show.new
  end

  def provider_index_page
    @provider_index_page ||= PageObjects::Providers::Index.new
  end
end
