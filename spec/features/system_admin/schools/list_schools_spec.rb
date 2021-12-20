# frozen_string_literal: true

require "rails_helper"

feature "List schools" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let!(:school) { create(:school, name: "Test 1") }

    before do
      given_i_am_authenticated(user: user)
    end

    scenario "list schools" do
      when_i_visit_the_school_index_page
      then_i_see_the_school
    end
  end

  def when_i_visit_the_school_index_page
    schools_index_page.load
  end

  def then_i_see_the_school
    expect(schools_index_page).to have_text("Test 1")
    expect(schools_index_page).to have_text(school.urn)
    expect(schools_index_page).to have_text(school.town)
    expect(schools_index_page).to have_text(school.postcode)
  end
end
