# frozen_string_literal: true

require "rails_helper"

feature "List providers" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }

    before do
      @provider = create(:dttp_provider, name: "Test 1")
    end

    scenario "list providers" do
      given_i_am_authenticated(user: user)
      when_i_visit_the_dttp_provider_index_page
      then_i_see_the_dttp_provider
    end
  end

  def when_i_visit_the_dttp_provider_index_page
    dttp_provider_index_page.load
  end

  def then_i_see_the_dttp_provider
    expect(dttp_provider_index_page).to have_text("Test 1")
  end

end
