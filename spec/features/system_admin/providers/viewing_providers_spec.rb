# frozen_string_literal: true

require "rails_helper"

feature "View providers" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }

    before do
      given_i_am_authenticated(user: user)
      when_i_visit_the_provider_index_page
    end

    scenario "i can view the providers" do
      then_i_see_the_provider
    end
  end

  def when_i_visit_the_provider_index_page
    providers_index_page.load
  end

  def then_i_see_the_provider
    expect(providers_index_page.provider_cards).not_to be_empty
  end
end
