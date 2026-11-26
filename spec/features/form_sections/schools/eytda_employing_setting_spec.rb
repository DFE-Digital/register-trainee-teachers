# frozen_string_literal: true

require "rails_helper"

feature "early years teacher degree apprenticeship employing setting",
        "feature_routes.early_years_teacher_degree_apprenticeship": true do
  background { given_i_am_authenticated }

  let!(:nursery_school) { create(:school, name: "Little Acorns Nursery School", urn: "107823", town: "Leeds", postcode: "LS6 2AB") }

  scenario "the training partner question goes on to the URN question" do
    given_an_eytda_trainee

    visit "/trainees/#{trainee.slug}/training-partners/details/edit"
    choose "No"
    click_on "Continue"
    then_i_see_the_urn_question
  end

  scenario "a setting with a URN is searched for, then its details are completed" do
    given_an_eytda_trainee

    when_i_visit_the_urn_question
    and_i_answer("Yes")
    expect(page).to have_css("h1", text: "Search for the employing setting")

    fill_in "Search for the employing setting", with: "Acorns"
    click_on "Continue"
    choose "Little Acorns Nursery School"
    click_on "Continue"

    expect(page).to have_css("h1", text: "Employing setting")
    expect(page).to have_text("Check the details of the early years setting or nursery where the trainee works")
    expect(page).to have_field("Name of employing setting", with: "Little Acorns Nursery School")
    expect(page).to have_field("Town or city", with: "Leeds")
    expect(page).to have_field("Postcode", with: "LS6 2AB")
    expect(page).to have_text("107823")

    fill_in "Address line 1", with: "1 Oak Road"
    click_on "Continue"

    then_i_see_the_setting("Little Acorns Nursery School", "1 Oak Road, Leeds, LS6 2AB", "URN 107823")
    expect(trainee.reload.employing_school).to eq(nursery_school)
  end

  scenario "a setting without a URN is typed in" do
    given_an_eytda_trainee

    when_i_visit_the_urn_question
    click_on "Continue"
    expect(page).to have_text("Select yes if the employing setting has a URN")

    and_i_answer("No")
    expect(page).to have_text("Enter the details of the early years setting or nursery where the trainee works.")
    expect(page).not_to have_text("URN")

    click_on "Continue"
    expect(page).to have_text("Enter the name of the employing setting")
    expect(page).to have_text("Enter address line 1, typically the building and street")
    expect(page).to have_text("Enter town or city")
    expect(page).to have_text("Enter postcode")

    when_i_enter_a_setting
    then_i_see_the_setting("Sunshine Day Nursery", "12 Mill Lane, Harrogate, HG1 4QT", "No URN")
    expect(trainee.reload).to have_attributes(employing_school_id: nil, employing_school_urn: nil, employing_school_town: "Harrogate")
  end

  scenario "a setting that can't be found in the search is typed in" do
    given_an_eytda_trainee

    visit "/trainees/#{trainee.slug}/employing-schools/edit"
    click_on "I cannot find the setting"
    when_i_enter_a_setting
    then_i_see_the_setting("Sunshine Day Nursery", "12 Mill Lane, Harrogate, HG1 4QT", "No URN")
  end

  scenario "Change on the confirm page goes to the URN question, with the answer selected" do
    given_an_eytda_trainee(employing_school_name: "Sunshine Day Nursery", employing_school_address_line_one: "12 Mill Lane",
                           employing_school_town: "Harrogate", employing_school_postcode: "HG1 4QT")

    visit "/trainees/#{trainee.slug}/schools/confirm"
    click_on "Change employing setting"
    then_i_see_the_urn_question
    expect(page).to have_checked_field("No")
  end

  scenario "the employing school question goes to the URN question" do
    given_an_eytda_trainee

    visit "/trainees/#{trainee.slug}/employing-schools/details/edit"
    then_i_see_the_urn_question
  end

  scenario "other routes still ask whether there's an employing school" do
    given_a_trainee_exists(:early_years_salaried, training_partner_not_applicable: true)

    visit "/trainees/#{trainee.slug}/employing-schools/details/edit"
    expect(page).to have_text("Is there an employing school?")
  end

private

  def given_an_eytda_trainee(**attributes)
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, :draft, training_partner_not_applicable: true, **attributes)
  end

  def when_i_visit_the_urn_question
    visit "/trainees/#{trainee.slug}/employing-setting/urn/edit"
  end

  def then_i_see_the_urn_question
    expect(page).to have_current_path("/trainees/#{trainee.slug}/employing-setting/urn/edit")
    expect(page).to have_css("h1", text: "Does the employing setting have a URN?")
    expect(page).to have_text("The employing setting may be a nursery or another early years setting. A school URN is not required if the setting does not have one.")
  end

  def and_i_answer(answer)
    choose answer
    click_on "Continue"
  end

  def when_i_enter_a_setting
    fill_in "Name of employing setting", with: "Sunshine Day Nursery"
    fill_in "Address line 1", with: "12 Mill Lane"
    fill_in "Town or city", with: "Harrogate"
    fill_in "Postcode", with: "HG1 4QT"
    click_on "Continue"
  end

  def then_i_see_the_setting(name, address, urn)
    expect(page).to have_current_path("/trainees/#{trainee.slug}/schools/confirm")
    expect(page).to have_css("h1", text: "Confirm training partner and employing setting")
    row = page.find(".govuk-summary-list__row", text: "Employing setting")
    expect(row).to have_text(name)
    expect(row).to have_text(address)
    expect(row).to have_text(urn)
  end
end
