# frozen_string_literal: true

require "rails_helper"

feature "Add user to lead partners" do
  let(:admin_user) { create(:user, system_admin: true) }
  let(:user) { create(:user, system_admin: true) }

  context "as a system admin with the `lead_partners` feature flag `off`" do
    before do
      given_i_am_authenticated(user: admin_user)
    end

    scenario "list lead partners page" do
      when_i_visit_a_user_page
      then_i_there_is_no_add_to_lead_partner_link

      when_i_visit_the_add_to_lead_partner_page
      then_i_see_a_404_error
    end
  end

  context "as a system admin", :feature_lead_partners do
    let(:user) { create(:user, system_admin: true) }
    let!(:school_lead_partner) { create(:lead_partner, :lead_school, name: "School Partner") }
    let!(:hei_lead_partner) { create(:lead_partner, :hei, name: "HEI Partner") }

    before do
      given_i_am_authenticated(user:)
    end

    scenario "list lead partners page" do
      when_i_visit_a_user_page
      and_i_click_the_lead_partner_link
      then_i_see_the_add_to_lead_partner_page

      when_i_select_a_lead_partner
      and_i_click_the_submit_button
      then_i_see_the_user_added_to_the_lead_partner
    end
  end

  def when_i_visit_a_user_page
    visit user_path(user)
  end

  def and_i_click_the_lead_partner_link
    click_on("Add user to a lead partner")
  end

  def then_i_there_is_no_add_to_lead_partner_link
    expect(page).not_to have_link("Add user to a lead partner")
  end

  def when_i_visit_the_add_to_lead_partner_page
    visit new_user_lead_partner_path(user)
  end

  def then_i_see_a_404_error
    expect(page).to have_http_status(:not_found)
  end

  def then_i_see_the_add_to_lead_partner_page
    expect(page).to have_current_path(new_user_lead_partner_path(user))
    expect(page).to have_content("Add a lead partner for #{user.name}")
  end

  def when_i_select_a_lead_partner
    fill_in "system-admin-user-lead-partners-form-query-field", with: school_lead_partner.name
    first("input#lead-partners-id", visible: false).set(school_lead_partner.id)
  end

  def and_i_click_the_submit_button
    click_on("Continue")
  end

  def then_i_see_the_user_added_to_the_lead_partner
    expect(page).to have_content("Lead partner added")
  end
end
