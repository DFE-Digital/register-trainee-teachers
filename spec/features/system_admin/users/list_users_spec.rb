# frozen_string_literal: true

require "rails_helper"

feature "List users" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let(:training_partner) { create(:training_partner, :school) }
    let(:provider) { create(:provider) }

    before do
      user.training_partners << lead_partner
      user.providers << provider
      given_i_am_authenticated(user:)
    end

    scenario "list users" do
      when_i_visit_the_user_index_page
      then_i_see_the_user
    end
  end

  def when_i_visit_the_user_index_page
    admin_users_index_page.load
  end

  def then_i_see_the_user
    expect(admin_users_index_page).to have_text(user.first_name)
    expect(admin_users_index_page).to have_text(user.last_name)
    expect(admin_users_index_page).to have_text(user.email)
    expect(admin_users_index_page).to have_text(lead_partner.name)
    expect(admin_users_index_page).to have_text(provider.name_and_code)
  end
end
