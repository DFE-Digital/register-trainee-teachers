# frozen_string_literal: true

require "rails_helper"

feature "Edit providers" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }

    before do
      given_i_am_authenticated(user: user)
      when_i_visit_the_provider_index_page
    end

    scenario "i can edit a provider" do
      when_i_click_on_provider_name
      and_i_click_edit_this_provider
      and_change_the_provider_name
      and_i_submit_the_form
      the_updated_provider_name_is_displayed
    end
  end

  def when_i_visit_the_provider_index_page
    provider_index_page.load
  end

  def when_i_click_on_provider_name
    provider_index_page.provider_card.name.click
  end

  def and_i_click_edit_this_provider
    provider_show_page.edit_this_provider.click
  end

  def and_change_the_provider_name
    fill_in :name, with: "Foo"
  end

  def and_i_submit_the_form
    new_provider_page.submit.click
  end

  def the_updated_provider_name_is_displayed
    expect(provider_show_page).to have_text("Foo")
  end
end
