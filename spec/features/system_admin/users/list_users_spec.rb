# frozen_string_literal: true

require "rails_helper"

feature "List users" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let(:lead_school) { create(:school, :lead) }
    let(:provider) { create(:provider) }

    before do
      user.lead_schools << lead_school
      user.providers << provider
      given_i_am_authenticated(user: user)
    end

    scenario "list users" do
      when_i_visit_the_user_index_page
      then_i_see_the_user
    end
  end

  def when_i_visit_the_user_index_page
    users_index_page.load
  end

  def then_i_see_the_user
    expect(users_index_page).to have_text(user.first_name)
    expect(users_index_page).to have_text(user.last_name)
    expect(users_index_page).to have_text(user.email)
    expect(users_index_page).to have_text(lead_school.name)
    expect(users_index_page).to have_text(provider.name)
  end
end
