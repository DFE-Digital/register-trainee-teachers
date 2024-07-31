# frozen_string_literal: true

require "rails_helper"

feature "Add user to lead partners" do
  let(:admin_user) { create(:user, system_admin: true) }
  let(:user) { create(:user, system_admin: true) }

  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let!(:school_lead_partner) { create(:lead_partner, :lead_school, name: "Garibaldi School") }
    let!(:hei_lead_partner) { create(:lead_partner, :hei, name: "Bourbon University") }

    before do
      given_i_am_authenticated(user:)
    end

    scenario "list lead partners page" do
      when_i_visit_the_user_page
      and_i_click_the_lead_partner_link
      then_i_see_the_add_to_lead_partner_page

      when_i_select_a_lead_partner
      and_i_click_the_submit_button
      then_i_see_the_user_added_to_the_lead_partner

      when_i_click_the_lead_partner_link
      then_i_see_the_lead_partner_detail_page
      and_i_see_the_user_has_been_added_to_the_lead_partner

      when_i_visit_the_user_page
      and_i_click_the_remove_link
      then_i_see_the_remove_lead_partner_page

      when_i_confirm_the_removal
      then_i_see_a_flash_message_to_confirm_the_removal
      and_i_no_longer_see_the_lead_partner_on_the_user_page
    end
  end

  context "as a system admin using the non-JS flow" do
    let(:user) { create(:user, system_admin: true) }
    let!(:school_lead_partner) { create(:lead_partner, :lead_school, name: "Garibaldi School") }
    let!(:hei_lead_partner1) { create(:lead_partner, :hei, name: "Bourbon University") }
    let!(:hei_lead_partner2) { create(:lead_partner, :hei, name: "Digestive University") }

    before do
      given_i_am_authenticated(user:)
    end

    scenario "list lead partners page" do
      when_i_visit_the_user_page
      and_i_click_the_lead_partner_link
      then_i_see_the_add_to_lead_partner_page

      when_i_enter_a_lead_partner_search_and_submit
      then_i_see_matching_results

      when_i_select_a_lead_partner_from_search_results
      then_i_see_the_user_added_to_the_hei_lead_partner
    end
  end

  def when_i_visit_the_user_page
    visit user_path(user)
  end

  def and_i_click_the_lead_partner_link
    click_on("Add user to a lead partner")
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
    expect(page).to have_link("Garibaldi School", href: lead_partner_path(school_lead_partner))
  end

  def when_i_click_the_lead_partner_link
    click_on("Garibaldi School")
  end

  def then_i_see_the_lead_partner_detail_page
    expect(page).to have_current_path(lead_partner_path(school_lead_partner))
    expect(page).to have_content("Garibaldi School")
  end

  def and_i_see_the_user_has_been_added_to_the_lead_partner
    expect(page).to have_content(user.name)
  end

  def and_i_click_the_remove_link
    within("table#lead-partners") do
      click_on("Remove")
    end
  end

  def then_i_see_the_remove_lead_partner_page
    expect(page).to have_current_path(edit_user_lead_partner_accessions_path(user, school_lead_partner))
    expect(page).to have_content("Yes I’m sure – remove #{user.name}’s access to Garibaldi School")
  end

  def when_i_confirm_the_removal
    click_on("Yes I’m sure – remove #{user.name}’s access to Garibaldi School")
  end

  def then_i_see_a_flash_message_to_confirm_the_removal
    expect(page).to have_content("User access removed successfully")
  end

  def and_i_no_longer_see_the_lead_partner_on_the_user_page
    expect(page).not_to have_content("Garibaldi School")
  end

  def when_i_enter_a_lead_partner_search_and_submit
    fill_in "system-admin-user-lead-partners-form-query-field", with: "Univ"
    click_on("Continue")
  end

  def then_i_see_matching_results
    expect(page).to have_content("Bourbon University")
    expect(page).to have_content("Digestive University")
  end

  def when_i_select_a_lead_partner_from_search_results
    choose(option: hei_lead_partner2.id)
    click_on("Continue")
  end

  def then_i_see_the_user_added_to_the_hei_lead_partner
    expect(page).to have_content("Lead partner added")
    expect(page).to have_link("Digestive University", href: lead_partner_path(hei_lead_partner2))
  end
end
