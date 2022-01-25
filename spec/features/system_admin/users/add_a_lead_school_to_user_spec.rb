# frozen_string_literal: true

require "rails_helper"

feature "creating a new lead school for a user" do
  let(:user) { create(:user, system_admin: true) }
  let(:dttp_id) { SecureRandom.uuid }
  let!(:user_to_be_updated) { create(:user, first_name: "James", last_name: "Rodney") }
  let!(:new_lead_school) { create(:school, :lead, name: "Richards School Supreme") }

  before do
    given_i_am_authenticated(user: user)
    when_i_visit_the_user_index_page
    and_i_click_on_the_user_name_link
    then_i_am_taken_to_the_user_show_page
    and_i_click_on_add_lead_school
    then_i_am_taken_to_the_add_lead_school_to_user_page
  end

  describe "adding a provider to a user" do
    context "valid details" do
      scenario "adding a new user record associated with a provider" do
        and_i_select_a_lead_school_from_the_dropdown
        and_i_click_submit
        then_i_am_taken_to_the_user_show_page
        and_i_see_the_new_lead_school
      end
    end
  end

private

  def when_i_visit_the_user_index_page
    users_index_page.load
  end

  def and_i_click_on_the_user_name_link
    users_index_page.users.find { |user| user.link.text == user_to_be_updated.name }.link.click
  end

  def then_i_am_taken_to_the_user_show_page
    expect(users_show_page.current_path).to eq("/system-admin/users/#{user_to_be_updated.id}")
  end

  def and_i_click_on_add_lead_school
    users_show_page.add_lead_school.click
  end

  def then_i_am_taken_to_the_add_lead_school_to_user_page
    expect(add_lead_school_to_user_page.current_path).to eq("/system-admin/users/#{user_to_be_updated.id}/lead_schools/new")
  end

  def and_i_select_a_lead_school_from_the_dropdown
    add_lead_school_to_user_page.lead_school_select.select("Richards School Supreme")
  end

  def and_i_click_submit
    add_lead_school_to_user_page.submit.click
  end

  def and_i_see_the_new_lead_school
    expect(users_show_page.lead_schools.map(&:text)).to include("#{new_lead_school.name} - #{new_lead_school.urn}")
  end
end
