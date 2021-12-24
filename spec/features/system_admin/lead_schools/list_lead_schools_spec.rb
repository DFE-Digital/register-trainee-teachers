# frozen_string_literal: true

require "rails_helper"

feature "List lead schools" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let!(:lead_school) { create(:school, :lead, name: "Test 1") }
    let!(:non_lead_school) { create(:school, name: "Test 2", lead_school: false) }

    before do
      given_i_am_authenticated(user: user)
    end

    scenario "list lead schools" do
      when_i_visit_the_lead_school_index_page
      then_i_see_the_lead_school
    end
  end

  def when_i_visit_the_lead_school_index_page
    lead_schools_index_page.load
  end

  def then_i_see_the_lead_school
    expect(lead_schools_index_page).to have_text("Test 1")
    expect(lead_schools_index_page).to have_text(lead_school.urn)
    expect(lead_schools_index_page).to have_text(lead_school.town)
    expect(lead_schools_index_page).to have_text(lead_school.postcode)

    expect(lead_schools_index_page).not_to have_text("Test 2")
  end
end
