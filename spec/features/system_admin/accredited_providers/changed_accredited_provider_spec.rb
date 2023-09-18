# frozen_string_literal: true

require "rails_helper"

feature "Change a trainee's accredited provider" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let(:trainee) { create(:trainee, :trn_received) }
    let(:new_provider) { create(:provider) }

    before do
      given_i_am_authenticated(user:)
      and_the_change_accredited_provider_feature_is_enabled
    end

    scenario "i can edit a trainee's accredited provider" do
      when_i_visit_the_trainee_detail_page
      and_i_click_the_change_provider_link
      then_i_see_the_change_accredited_providers_page

      when_i_select_a_provider
      and_click_continue
      then_i_see_the_reasons_page
    end
  end

  def and_the_change_accredited_provider_feature_is_enabled
    enable_features(:change_accredited_provider)
  end

  def when_i_visit_the_trainee_detail_page
    visit "/trainees/#{trainee.slug}"
  end

  def and_i_click_the_change_provider_link
    within ".govuk-summary-list__row.accrediting-provider" do
      click_on "Change"
    end
  end

  def then_i_see_the_change_accredited_providers_page
    expect(page).to have_content("Change accredited provider")
  end
end
