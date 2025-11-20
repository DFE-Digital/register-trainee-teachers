# frozen_string_literal: true

require "rails_helper"

feature "Edit providers" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true, providers: [provider]) }
    let(:existing_provider) { create(:provider) }
    let(:accreditation_id) { Faker::Number.number(digits: 4) }
    let(:provider) { build(:provider) }
    let(:authentication_token) { create(:authentication_token, provider:, created_by: user) }

    before do
      given_i_am_authenticated(user:)
      and_the_provider_has_an_authentication_token
      when_i_visit_the_provider_index_page
      when_i_click_on_provider_name
      and_i_click_edit_this_provider
    end

    scenario "i can edit a provider" do
      when_i_change_the_provider_name
      and_i_submit_the_form
      the_updated_provider_name_is_displayed
    end

    scenario "editing the accreditation ID successfully" do
      when_i_enter_accreditation_id
      and_i_submit_the_form
      then_i_should_see_the_provider_index_page
    end

    scenario "editing with an existing accreditation ID" do
      when_i_enter_an_existing_accreditation_id
      and_i_submit_the_form
      then_i_see_accreditation_id_uniqueness_error
    end

    scenario "discarding the provider" do
      when_i_am_on_the_edit_page
      and_i_click_on_the_delete_button
      and_i_am_on_the_confirmation_page
      and_i_click_on_the_delete_confirmation_button
      then_i_am_on_the_providers_listing_page
      and_the_provider_is_deleted
      and_the_authentication_token_is_revoked
    end
  end

private

  def when_i_am_on_the_edit_page
    expect(page).to have_current_path("/system-admin/providers/#{provider.id}/edit")
    expect(page).not_to have_css("h1 > .govuk-tag.govuk-tag--red", text: "Deleted")
  end

  def and_i_click_on_the_delete_button
    page.click_on("Delete this provider")
  end

  def and_i_am_on_the_confirmation_page
    expect(page).to have_current_path("/system-admin/providers/#{provider.id}/confirm-delete")
  end

  def and_i_click_on_the_delete_confirmation_button
    expect { page.click_on("Delete this provider") }.to change(provider.users, :count).from(1).to(0)
  end

  def then_i_am_on_the_providers_listing_page
    expect(page).to have_current_path("/system-admin/providers")
  end

  def and_the_provider_is_deleted
    expect(page).to have_css(".govuk-notification-banner--success > * .govuk-notification-banner__heading", text: "Provider successfully deleted")

    expect(page).to have_css(".govuk-tag.govuk-tag--red", text: "Deleted")
    expect(page).to have_text("0 users")
  end

  def and_the_authentication_token_is_revoked
    authentication_token.reload
    expect(authentication_token).to be_revoked
  end

  def and_the_provider_has_an_authentication_token
    authentication_token
  end

  def when_i_visit_the_provider_index_page
    providers_index_page.load
  end

  def when_i_click_on_provider_name
    providers_index_page.provider_cards.first.name.click
  end

  def and_i_click_edit_this_provider
    provider_show_page.edit_this_provider.click
  end

  def when_i_change_the_provider_name
    fill_in :name, with: "Foo"
  end

  def when_i_enter_accreditation_id
    new_provider_page.accreditation_id.set(accreditation_id)
  end

  def when_i_enter_an_existing_accreditation_id
    new_provider_page.accreditation_id.set(existing_provider.accreditation_id)
  end

  def and_i_submit_the_form
    new_provider_page.submit.click
  end

  def the_updated_provider_name_is_displayed
    expect(provider_show_page).to have_text("Foo")
  end

  def then_i_should_see_the_provider_index_page
    expect(providers_index_page).to be_displayed
  end

  def then_i_see_accreditation_id_uniqueness_error
    translation_key_prefix = "activerecord.errors.models.provider.attributes"

    expect(new_provider_page).to have_text(
      I18n.t("#{translation_key_prefix}.accreditation_id.taken"),
    )
  end
end
