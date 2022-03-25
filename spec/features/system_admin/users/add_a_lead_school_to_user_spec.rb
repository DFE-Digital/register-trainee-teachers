# frozen_string_literal: true

require "rails_helper"

feature "creating a new lead school for a user" do
  let(:user) { create(:user, system_admin: true) }
  let!(:user_to_be_updated) { create(:user, first_name: "James", last_name: "Rodney") }

  before do
    given_i_am_authenticated(user: user)
    and_a_number_of_lead_schools_exist
    when_i_visit_the_user_index_page
    and_i_click_on_the_user_name_link
    then_i_am_taken_to_the_user_show_page
    and_i_click_on_add_lead_school
    then_i_am_taken_to_the_add_lead_school_to_user_page
  end

  describe "adding a lead school to a user" do
    context "with javascript" do
      scenario "works", js: true do
        and_i_fill_in_my_lead_school
        and_i_click_the_first_item_in_the_list
        and_i_continue
        then_i_am_taken_to_the_user_show_page
        and_i_see_the_new_lead_school
      end

      context "when a lead school is not selected" do
        it "works", js: true do
          and_i_fill_in_my_lead_school
          and_i_continue
          then_i_am_redirected_to_the_lead_schools_page
        end
      end
    end

    context "without javascript" do
      scenario "works" do
        and_i_fill_in_my_lead_school_without_js
        and_i_continue
        then_i_am_redirected_to_the_lead_schools_page
      end
    end
  end

private

  def and_a_number_of_lead_schools_exist
    @lead_schools = create_list(:school, 5, :lead)
  end

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
    expect(add_lead_school_to_user_page.current_path).to eq("/system-admin/users/#{user_to_be_updated.id}/lead-schools/new")
  end

  def my_lead_school
    @my_lead_school ||= @lead_schools.sample
  end

  def and_i_fill_in_my_lead_school
    add_lead_school_to_user_page.lead_school.fill_in with: my_lead_school.name
  end

  def and_i_fill_in_my_lead_school_without_js
    add_lead_school_to_user_page.no_js_lead_school.fill_in with: my_lead_school.name
  end

  def and_i_click_the_first_item_in_the_list
    # this will cause capybara to wait for the list to be filtered before clicking 'first'
    expect(add_lead_school_to_user_page).to have_autocomplete_list_items(count: 1)
    click(add_lead_school_to_user_page.autocomplete_list_items.first)
  end

  def and_i_continue
    click(add_lead_school_to_user_page.submit)
  end

  def and_i_see_the_new_lead_school
    expect(users_show_page.lead_schools.map(&:text)).to include("#{my_lead_school.name} - #{my_lead_school.urn}")
  end

  def then_i_am_redirected_to_the_lead_schools_page
    expect(user_lead_schools_page).to be_displayed
  end
end
