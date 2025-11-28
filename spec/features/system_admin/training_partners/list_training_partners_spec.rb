# frozen_string_literal: true

require "rails_helper"

feature "List training partners" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let!(:school_lead_partner) { create(:lead_partner, :school, name: "School Partner") }
    let!(:hei_lead_partner) { create(:lead_partner, :hei, name: "HEI Partner") }

    before do
      given_i_am_authenticated(user:)
    end

    scenario "list training partners page" do
      when_i_visit_the_system_admin_page
      and_i_click_the_lead_partner_link
      then_i_see_the_lead_partners_index_page
      and_i_see_the_hei_lead_partner
      and_i_see_the_school_lead_partner

      when_i_click_the_school_lead_partner
      then_i_see_the_school_lead_partner_detail_page

      when_i_click_the_back_button
      then_i_see_the_lead_partners_index_page

      when_i_click_the_hei_lead_partner
      then_i_see_the_hei_lead_partner_detail_page
    end
  end

  def when_i_visit_the_system_admin_page
    visit users_path
  end

  def and_i_click_the_lead_partner_link
    click_on "Training partners"
  end

  def then_i_see_the_lead_partners_index_page
    expect(page).to have_current_path(training_partners_path)
  end

  def and_i_see_the_hei_lead_partner
    expect(page).to have_text("HEI Partner")
    expect(page).to have_text(hei_lead_partner.urn)
  end

  def and_i_see_the_school_lead_partner
    expect(page).to have_text("School Partner")
    expect(page).to have_text(school_lead_partner.urn)
  end

  def when_i_click_the_school_lead_partner
    click_on "School Partner"
  end

  def then_i_see_the_school_lead_partner_detail_page
    expect(page).to have_current_path(training_partner_path(school_lead_partner.id))
    expect(page).to have_text("School Partner")
    expect(page).to have_text(school_lead_partner.urn)
    expect(page).to have_text(school_lead_partner.school.town)
    expect(page).to have_text(school_lead_partner.school.postcode)
    expect(page).not_to have_link("View funding")
  end

  def when_i_click_the_back_button
    click_on "Back"
  end

  def when_i_click_the_hei_lead_partner
    click_on "HEI Partner"
  end

  def then_i_see_the_hei_lead_partner_detail_page
    expect(page).to have_current_path(training_partner_path(hei_lead_partner.id))
    expect(page).to have_text("HEI Partner")
    expect(page).to have_text(hei_lead_partner.provider.ukprn)
    expect(page).to have_text(hei_lead_partner.provider.code)
    expect(page).not_to have_link("View funding")
  end
end
