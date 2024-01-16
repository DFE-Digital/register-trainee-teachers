# frozen_string_literal: true

require "rails_helper"

feature "Creating a funding upload" do
  before do
    given_i_am_authenticated(user:)
    when_i_visit_the_funding_upload_page_for(funding_type)
    then_i_am_on_the_correct_funding_upload_page
  end

  scenario "can submit a valid funding upload for processing" do
    when_i_submit_a_valid_funding_upload
    then_i_see_the_confirmation_page
  end

  scenario "cannot submit an invalid funding upload" do
    when_i_submit_invalid_funding_upload_data
    then_i_see_the_errors
  end

private

  def user
    create(:user, :system_admin)
  end

  def when_i_visit_the_funding_upload_page_for(funding_type)
    visit funding_type_url_for(funding_type)
  end

  def funding_type
    @funding_type ||= SystemAdmin::FundingUpload.funding_types.keys.sample
  end

  def funding_type_url_for(funding_type) = "/system-admin/funding-uploads/new?funding_type=#{funding_type}"

  def then_i_am_on_the_correct_funding_upload_page
    expect(page).to have_current_path(funding_type_url_for(funding_type))
    expect(page).to have_content(t("components.page_titles.funding_uploads.new.#{funding_type}"))
    expect(page).to have_content(t("system_admin.funding_uploads.new.#{funding_type}"))
  end

  def when_i_submit_a_valid_funding_upload
    select("January", from: "system_admin_funding_upload_form[month]")
    attach_file("system_admin_funding_upload_form[file]", file_fixture("test.csv"))
    submit_form
  end

  def when_i_submit_invalid_funding_upload_data = submit_form

  def submit_form = click_on("Upload the file")

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(funding_uploads_confirmation_path)
  end

  def then_i_see_the_errors
    expect(page).to have_content("Select month")
    expect(page).to have_content("Select a CSV file")
  end
end
