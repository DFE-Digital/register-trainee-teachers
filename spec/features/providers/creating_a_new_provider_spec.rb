# frozen_string_literal: true

require "rails_helper"

feature "Creating a new provider" do
  let(:user) { create(:user, system_admin: true) }
  let(:dttp_id) { SecureRandom.uuid }

  before do
    given_i_am_authenticated(user: user)
    when_i_visit_the_provider_index_page
    and_i_click_on_add_provider_button
  end

  scenario "submitting with valid parameters" do
    and_i_fill_in_name
    and_i_fill_in_dttp_id
    and_i_select_apply_sync_enabled
    and_i_submit_the_form
    then_i_should_see_the_provider_index_page
  end

  scenario "submitting with invalid parameters" do
    and_i_submit_the_form
    then_i_see_error_messages
  end

private

  def when_i_visit_the_provider_index_page
    provider_index_page.load
  end

  def and_i_click_on_add_provider_button
    provider_index_page.add_provider_link.click
  end

  def and_i_fill_in_name
    new_provider_page.name.set("Provider A")
  end

  def and_i_fill_in_dttp_id
    new_provider_page.dttp_id.set(dttp_id)
  end

  def and_i_select_apply_sync_enabled
    new_provider_page.apply_sync_enabled.set(true)
  end

  def and_i_submit_the_form
    new_provider_page.submit.click
  end

  def then_i_should_see_the_provider_index_page
    expect(provider_index_page).to be_displayed
  end

  def then_i_see_error_messages
    translation_key_prefix = "activerecord.errors.models.provider.attributes"

    expect(page).to have_text(
      I18n.t("#{translation_key_prefix}.name.blank"),
    )
    expect(page).to have_text(
      I18n.t("#{translation_key_prefix}.dttp_id.invalid"),
    )
  end
end
