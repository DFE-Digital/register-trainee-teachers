require "rails_helper"

feature "Editing a School", type: :feature do
  let(:user) { create(:user, system_admin: true) }
  let!(:school) { create(:school, :closed, name: "Test 1") }

  before do
    given_i_am_authenticated(user:)
  end

  scenario "A System Admin edits a School" do
    when_i_visit_the_school_index_page
    and_i_see_the_list_of_schools
    and_i_click_on_a_school_name
    then_i_see_the_school_show_page
    when_i_click_on_back
    then_i_see_the_list_of_schools
    when_i_click_on_a_school_name
    and_i_click_on_change
    and_i_see_the_school_edit_page
    and_i_edit_the_school
    and_i_click_on_continue
    then_i_see_the_confirm_school_details_page
    when_i_click_on_back
    then_i_see_the_school_edit_page(lead_partner: true)
    when_i_click_on_continue
    and_i_click_on_confirm
    then_i_see_the_updated_school
  end

  scenario "A System Admin cancels editing a School" do

  end

  def when_i_visit_the_school_index_page
    schools_index_page.load
  end

  def and_i_see_the_list_of_schools
    expect(schools_index_page).to have_text("Test 1")
    expect(schools_index_page).to have_text(school.urn)
    expect(schools_index_page).to have_text(school.town)
    expect(schools_index_page).to have_text(school.postcode)
    expect(schools_index_page).to have_text(false)
  end

  def and_i_click_on_a_school_name
    click_on "Test 1"
  end

  def then_i_see_the_school_show_page
    expect(show_school_page).to have_text("Name Test 1")
    expect(show_school_page).to have_text("URN #{school.urn}")
    expect(show_school_page).to have_text("Town #{school.town}")
    expect(show_school_page).to have_text("Postcode #{school.postcode}")
    expect(show_school_page).to have_text("Open date #{school.open_date&.strftime("%d %B %Y")}")
    expect(show_school_page).to have_text("Close date #{school.close_date&.strftime("%d %B %Y")}")
    expect(show_school_page).to have_text("Is a lead partner No Change")
  end

  def when_i_click_on_back
    click_link "Back"
  end

  def when_i_click_on_change
    first(:link, "Change").click
  end

  def and_i_see_the_school_edit_page(lead_partner: false)
    expect(edit_school_page).to have_text("Edit - Test 1")
    expect(edit_school_page).to have_lead_partner_radio_button_checked(lead_partner)
  end

  def and_i_edit_the_school
    edit_school_page.select_radio_button(true)
  end

  def and_i_click_on_continue
    edit_school_page.continue_button.click
  end

  def then_i_see_the_updated_school
    expect(show_school_page).to be_displayed
    expect(show_school_page).to have_text("Name Test 1")
    expect(show_school_page).to have_text("URN #{school.urn}")
    expect(show_school_page).to have_text("Town #{school.town}")
    expect(show_school_page).to have_text("Postcode #{school.postcode}")
    expect(show_school_page).to have_text("Open date #{school.open_date&.strftime("%d %B %Y")}")
    expect(show_school_page).to have_text("Close date #{school.close_date&.strftime("%d %B %Y")}")
    expect(show_school_page).to have_text("Is a lead partner Yes Change")
  end

  def then_i_see_the_confirm_school_details_page
    expect(confirm_school_details_page).to be_displayed
    expect(confirm_school_details_page).to have_text("Name Test 1")
    expect(confirm_school_details_page).to have_text("URN #{school.urn}")
    expect(confirm_school_details_page).to have_text("Town #{school.town}")
    expect(confirm_school_details_page).to have_text("Postcode #{school.postcode}")
    expect(confirm_school_details_page).to have_text("Open date #{school.open_date&.strftime("%d %B %Y")}")
    expect(confirm_school_details_page).to have_text("Close date #{school.close_date&.strftime("%d %B %Y")}")
    expect(confirm_school_details_page).to have_text("Is a lead partner Yes Change")
  end

  def when_i_click_on_confirm
    confirm_school_details_page.confirm_button.click
  end

  alias_method :then_i_see_the_list_of_schools, :and_i_see_the_list_of_schools
  alias_method :when_i_click_on_a_school_name, :and_i_click_on_a_school_name
  alias_method :and_i_click_on_change, :when_i_click_on_change
  alias_method :then_i_see_the_school_edit_page, :and_i_see_the_school_edit_page
  alias_method :when_i_click_on_continue, :and_i_click_on_continue
  alias_method :and_i_click_on_confirm, :when_i_click_on_confirm
end
