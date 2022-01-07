# frozen_string_literal: true

require "rails_helper"

feature "Show lead school" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let!(:lead_school) { create(:school, :lead, name: "Test 1") }

    before do
      given_i_am_authenticated(user: user)
    end

    scenario "show lead school" do
      when_i_visit_the_lead_school_show_page
      then_i_see_the_lead_school
    end
  end

  def when_i_visit_the_lead_school_show_page
    lead_school_show_page.load(id: lead_school.id)
  end

  def then_i_see_the_lead_school
    expect(lead_school_show_page).to have_text("Test 1")
    expect(lead_school_show_page).to have_text(lead_school.urn)
    expect(lead_school_show_page).to have_text(lead_school.town)
    expect(lead_school_show_page).to have_text(lead_school.postcode)
  end
end
