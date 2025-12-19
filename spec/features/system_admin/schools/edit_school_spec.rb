# frozen_string_literal: true

require "rails_helper"

feature "Editing a School" do
  let(:user) { create(:user, system_admin: true) }

  let!(:school) { create(:school, :closed, name: "Test 1") }
  let(:school_form) { SystemAdmin::SchoolForm.new(school, params: { training_partner: nil }) }

  before do
    given_i_am_authenticated(user:)
  end

  scenario "A System Admin edits a School" do
    when_i_visit_the_training_partners_index_page
    then_i_dont_see_the_school_as_a_training_partner

    when_i_visit_the_school_index_page
    and_i_see_the_list_of_schools(training_partner: "No")
    and_i_click_on_a_school_name
    then_i_see_the_school_show_page(training_partner: "No")

    when_i_click_on_back
    then_i_see_the_list_of_schools(training_partner: "No")

    when_i_click_on_a_school_name
    and_i_click_on_change
    and_i_see_the_school_edit_page(training_partner: false)
    and_i_edit_the_school(training_partner: true)
    and_i_click_on_continue
    then_i_see_the_confirm_school_details_page(training_partner: "Yes")

    when_i_click_on_back
    then_i_see_the_school_edit_page(training_partner: true)

    when_i_click_on_continue
    and_i_click_on_confirm
    then_i_see_the_school_show_page(training_partner: "Yes")

    when_i_click_on_back
    then_i_see_the_list_of_schools(training_partner: "Yes")

    when_i_visit_the_training_partners_index_page
    then_i_see_the_school_as_a_training_partner

    when_i_visit_the_school_index_page
    and_i_see_the_list_of_schools(training_partner: "Yes")
    and_i_click_on_a_school_name
    and_i_see_the_school_show_page(training_partner: "Yes")
    and_i_click_on_change
    and_i_see_the_school_edit_page(training_partner: true)
    and_i_edit_the_school(training_partner: false)
    and_i_click_on_continue
    and_i_see_the_confirm_school_details_page(training_partner: "No")
    and_i_click_on_confirm
    then_i_see_the_school_show_page(training_partner: "No")

    when_i_visit_the_training_partners_index_page
    then_i_dont_see_the_school_as_a_training_partner
  end

  scenario "A System Admin cancels editing a School" do
    when_i_visit_the_school_index_page
    and_i_see_the_list_of_schools(training_partner: "No")
    and_i_click_on_a_school_name
    then_i_see_the_school_show_page(training_partner: "No")

    when_i_click_on_change
    then_i_see_the_school_edit_page(training_partner: false)

    when_i_click_on_cancel
    then_i_see_the_school_show_page(training_partner: "No")

    when_i_click_on_change
    and_i_see_the_school_edit_page(training_partner: false)
    and_i_edit_the_school(training_partner: true)
    and_i_click_on_continue
    and_i_see_the_confirm_school_details_page(training_partner: "Yes")
    and_i_click_on_cancel
    then_i_see_the_school_show_page(training_partner: "No")

    when_i_click_on_change
    then_i_see_the_school_edit_page(training_partner: false)

    when_i_visit_the_school_index_page
    then_i_see_the_list_of_schools(training_partner: "No")
  end

  scenario "A System Admin edits a School and gets errors" do
    when_i_visit_the_school_index_page
    and_i_see_the_list_of_schools(training_partner: "No")
    and_i_click_on_a_school_name
    and_i_see_the_school_show_page(training_partner: "No")
    and_i_click_on_change
    and_i_see_the_school_edit_page(training_partner: false)
    and_i_edit_the_school(training_partner: true)

    allow(SystemAdmin::SchoolForm).to receive(:new).and_return(school_form)

    and_i_click_on_continue
    then_i_see_an_error_message

    allow(SystemAdmin::SchoolForm).to receive(:new).and_call_original

    edit_school_page.load(id: school.id)

    and_i_edit_the_school(training_partner: true)
    and_i_click_on_continue
    and_i_see_the_confirm_school_details_page(training_partner: "Yes")

    allow(SystemAdmin::SchoolForm).to receive(:new).and_return(school_form)

    when_i_click_on_confirm
    then_i_see_an_error_message
  end

  def then_i_see_an_error_message
    expect(edit_school_page.error_summary).to have_text("is not included in the list")
  end

  def when_i_visit_the_school_index_page
    schools_index_page.load
  end

  def when_i_visit_the_training_partners_index_page
    training_partners_index_page.load
  end

  def then_i_dont_see_the_school_as_a_training_partner
    expect(training_partners_index_page).not_to have_text("Test 1")
  end

  def then_i_see_the_school_as_a_training_partner
    expect(training_partners_index_page).to have_text("Test 1")
  end

  def and_i_see_the_list_of_schools(training_partner:)
    expect(schools_index_page).to have_text("Test 1")
    expect(schools_index_page).to have_text(school.urn)
    expect(schools_index_page).to have_text(school.town)
    expect(schools_index_page).to have_text(school.postcode)
    expect(schools_index_page).to have_text(training_partner)
  end

  def and_i_click_on_a_school_name
    click_on "Test 1"
  end

  def then_i_see_the_school_show_page(training_partner:)
    expect(show_school_page).to have_text("Name Test 1")
    expect(show_school_page).to have_text("URN #{school.urn}")
    expect(show_school_page).to have_text("Town #{school.town}")
    expect(show_school_page).to have_text("Postcode #{school.postcode}")
    expect(show_school_page).to have_text("Open date #{school.open_date&.strftime('%d %B %Y')}")
    expect(show_school_page).to have_text("Close date #{school.close_date&.strftime('%d %B %Y')}")
    expect(show_school_page).to have_text("Is a training partner? #{training_partner} Change")
  end

  def when_i_click_on_cancel
    edit_school_page.cancel_link.click
  end

  def when_i_click_on_back
    edit_school_page.back_link.click
  end

  def when_i_click_on_change
    first(:link, "Change").click
  end

  def and_i_see_the_school_edit_page(training_partner:)
    expect(edit_school_page).to have_text("Edit - Test 1")
    expect(edit_school_page).to have_training_partner_radio_button_checked(training_partner)
  end

  def and_i_edit_the_school(training_partner:)
    edit_school_page.select_radio_button(training_partner)
  end

  def and_i_click_on_continue
    edit_school_page.continue_button.click
  end

  def then_i_see_the_confirm_school_details_page(training_partner:)
    expect(confirm_school_details_page).to be_displayed
    expect(confirm_school_details_page).to have_text("Name Test 1")
    expect(confirm_school_details_page).to have_text("URN #{school.urn}")
    expect(confirm_school_details_page).to have_text("Town #{school.town}")
    expect(confirm_school_details_page).to have_text("Postcode #{school.postcode}")
    expect(confirm_school_details_page).to have_text("Open date #{school.open_date&.strftime('%d %B %Y')}")
    expect(confirm_school_details_page).to have_text("Close date #{school.close_date&.strftime('%d %B %Y')}")
    expect(confirm_school_details_page).to have_text("Is a training partner? #{training_partner} Change")
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
  alias_method :and_i_click_on_cancel, :when_i_click_on_cancel
  alias_method :and_i_see_the_school_show_page, :then_i_see_the_school_show_page
  alias_method :and_i_see_the_confirm_school_details_page, :then_i_see_the_confirm_school_details_page
end
