# frozen_string_literal: true

require "rails_helper"

feature "Viewing duplicate Apply applications" do
  let(:user) { create(:user, system_admin: true) }

  scenario "shows the duplicate Apply applications" do
    given_i_am_authenticated(user:)
    and_there_are_duplicate_apply_applications
    when_i_visit_the_duplicate_apply_applications_index_page
    then_i_should_see_the_duplicate_apply_applications

    when_i_click_on_a_duplicate_apply_application
    then_i_should_see_the_candidate_name
    and_i_should_see_the_application_details

    when_i_click_on_the_trainee_link
    then_i_should_see_the_trainee_page
  end

  scenario "shows the duplicate Apply applications with no matching trainee record" do
    given_i_am_authenticated(user:)
    and_there_are_duplicate_apply_applications_without_matching_trainee
    when_i_visit_the_duplicate_apply_applications_index_page
    then_i_should_see_the_duplicate_apply_applications

    when_i_click_on_a_duplicate_apply_application
    then_i_should_see_the_candidate_name
    and_i_should_see_the_application_details
    and_i_should_not_see_the_trainee_link
  end

  def and_there_are_duplicate_apply_applications
    @application = JSON.parse(ApiStubs::RecruitsApi.application)
    @importable_apply_application = create(:apply_application, :importable)
    @imported_apply_application = create(:apply_application, :imported)
    @trainee = create(:trainee, :trn_received)
    @application["attributes"]["candidate"]["first_name"] = @trainee.first_names
    @application["attributes"]["candidate"]["last_name"] = @trainee.last_name
    @application["attributes"]["candidate"]["date_of_birth"] = @trainee.date_of_birth.iso8601
    @non_matching_trainee = create(:trainee, :trn_received)
    @duplicate_apply_application = create(
      :apply_application,
      :non_importable_duplicate,
      provider: @trainee.provider,
      application: @application,
    )
  end

  def and_there_are_duplicate_apply_applications_without_matching_trainee
    @application = JSON.parse(ApiStubs::RecruitsApi.application)
    @importable_apply_application = create(:apply_application, :importable)
    @imported_apply_application = create(:apply_application, :imported)
    @duplicate_apply_application = create(
      :apply_application,
      :non_importable_duplicate,
      application: @application,
    )
  end

  def when_i_visit_the_duplicate_apply_applications_index_page
    visit users_path
    click_on "Duplicate Apply applications"
  end

  def then_i_should_see_the_duplicate_apply_applications
    expect(page).to have_current_path(duplicate_apply_applications_path)
    candidate_attributes = @duplicate_apply_application.application.dig("attributes", "candidate")
    expect(page).to have_content(candidate_attributes["first_name"])
    expect(page).to have_content(candidate_attributes["last_name"])
    expect(page).to have_content(@duplicate_apply_application.created_at.to_fs(:govuk_short))
  end

  def when_i_click_on_a_duplicate_apply_application
    click_on "View"
  end

  def then_i_should_see_the_candidate_name
    expect(page).to have_content(@duplicate_apply_application.candidate_full_name)
  end

  def and_i_should_see_the_application_details
    expect(page).to have_content(@application["attributes"]["support_reference"])
    expect(page).to have_content(@application["attributes"]["candidate"]["domicile"])
    expect(page).to have_content(@application["attributes"]["contact_details"]["phone_number"])
    expect(page).to have_content(@application["attributes"]["course"]["course_code"])
  end

  def when_i_click_on_the_trainee_link
    within(".application-record-card") do
      click_on @duplicate_apply_application.candidate_full_name
    end
  end

  def then_i_should_see_the_trainee_page
    expect(page).to have_current_path(trainee_path(@trainee))
  end

  def and_i_should_not_see_the_trainee_link
    expect(page).to have_content("None found")
  end

  def then_i_should_see_the_trainee_page
    expect(page).to have_current_path(trainee_path(@trainee))
    expect(page).not_to have_css(".application-record-card")
  end
end
