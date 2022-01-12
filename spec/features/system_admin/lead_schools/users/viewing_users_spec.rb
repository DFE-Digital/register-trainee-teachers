# frozen_string_literal: true

require "rails_helper"

feature "View users" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let(:lead_school) { create(:school, :lead) }
    let!(:user_with_lead_school) { create(:user, lead_schools: [lead_school]) }

    scenario "I can view the users" do
      given_i_am_authenticated(user: user)
      when_i_visit_the_lead_school_index_page
      and_i_click_on_a_lead_school
      then_i_am_taken_to_the_lead_school_show_page
      then_i_see_the_user_with_lead_school
    end
  end

  def when_i_visit_the_lead_school_index_page
    lead_schools_index_page.load
  end

  def and_i_click_on_a_lead_school
    lead_schools_index_page.lead_school_links.click
  end

  def then_i_am_taken_to_the_lead_school_show_page
    expect(lead_school_show_page).to be_displayed(id: lead_school.id)
  end

  def then_i_see_the_user_with_lead_school
    expect(lead_school_show_page).to have_text(user_with_lead_school.name)
  end
end
