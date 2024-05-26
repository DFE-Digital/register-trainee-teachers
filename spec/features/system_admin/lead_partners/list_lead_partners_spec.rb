# frozen_string_literal: true

require "rails_helper"

feature "List lead partners" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let!(:school_lead_partner) { create(:lead_partner, :lead_school, name: "School Partner") }
    let!(:hei_lead_partner) { create(:lead_partner, :hei, name: "HEI Partner") }

    before do
      given_i_am_authenticated(user:)
    end

    scenario "list lead partners page" do
      when_i_visit_the_system_admin_page
      and_i_click_the_lead_partner_link
      then_i_see_the_lead_partners_index_page
      and_i_see_the_hei_lead_partner
      and_i_see_the_school_lead_partner
    end
  end

  def when_i_visit_the_system_admin_page
    visit users_path
  end

  def and_i_click_the_lead_partner_link
    click_on "Lead partners"
  end

  def then_i_see_the_lead_partners_index_page
    expect(page).to have_current_path(lead_partners_path)
  end

  def and_i_see_the_hei_lead_partner
    expect(page).to have_text("HEI Partner")
    expect(page).to have_text(hei_lead_partner.urn)
  end

  def and_i_see_the_school_lead_partner
    expect(page).to have_text("School Partner")
    expect(page).to have_text(school_lead_partner.urn)
  end
end
