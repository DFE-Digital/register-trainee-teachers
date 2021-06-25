# frozen_string_literal: true

require "rails_helper"

feature "List providers" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }

    before do
      @dttp_provider = create(:dttp_provider, name: "Test 1")
      given_i_am_authenticated(user: user)
    end

    scenario "list providers" do
      when_i_visit_the_dttp_provider_index_page
      then_i_see_the_dttp_provider
    end

    scenario "creating a provider from dttp_provider" do
      when_i_visit_the_dttp_provider_index_page
      and_i_click_on_create_provider_button
      then_i_am_redirected_to_the_provider_page
    end

    scenario "navigating from dttp_provider to provider" do
      when_a_provider_is_imported
      when_i_visit_the_dttp_provider_index_page
      and_i_click_on_view_button
      then_i_am_redirected_to_the_provider_page
    end
  end

  def when_i_visit_the_dttp_provider_index_page
    dttp_provider_index_page.load
  end

  def then_i_see_the_dttp_provider
    expect(dttp_provider_index_page).to have_text("Test 1")
  end

  def and_i_click_on_create_provider_button
    click_on "Create"
  end

  def then_i_am_redirected_to_the_provider_page
    expect(page).to have_current_path("/system-admin/providers/#{provider.id}", ignore_query: true)
  end

  def when_a_provider_is_imported
    create(:provider, dttp_id: @dttp_provider.dttp_id)
  end

  def and_i_click_on_view_button
    click_on "View"
  end

  def provider
    @provider ||= Provider.find_by(dttp_id: @dttp_provider.dttp_id)
  end
end
