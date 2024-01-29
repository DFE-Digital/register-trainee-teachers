# frozen_string_literal: true

require "rails_helper"

feature "Creating a funding upload" do
  before do
    given_i_am_authenticated(user:)
    and_there_are_some_schools
    and_there_are_some_providers
    when_i_visit_the_funding_upload_page_for(funding_type)
    then_i_am_on_the_correct_funding_upload_page
  end

  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    example.run
    ActiveJob::Base.queue_adapter = original_adapter
  end

  scenario "can submit a valid funding upload for processing" do
    when_i_submit_a_valid_funding_upload
    and_i_return_to_the_funding_uploads_page
    then_i_see_the_funding_upload_details_for(funding_type)
  end

  scenario "cannot submit an invalid funding upload" do
    when_i_submit_invalid_funding_upload_data
    then_i_see_the_errors
  end

private

  def user
    create(:user, :system_admin)
  end

  def and_there_are_some_schools
    schools_data = [
      { name: "Lead school 1", urn: "1111" },
      { name: "Lead school 2", urn: "2222" },
      { name: "Lead school 1", urn: "131238" },
      { name: "Lead school 2", urn: "135438" },
      { name: "Lead school 3", urn: "105491" },
      { name: "Lead school 4", urn: "103527" },
    ]

    schools_data.each do |school_data|
      create(:school, :lead, :open, school_data)
    end
  end

  def and_there_are_some_providers
    providers_data = [
      { name: "Provider 1", accreditation_id: "1111" },
      { name: "Provider 2", accreditation_id: "2222" },
      { name: "Provider 1", accreditation_id: "5635" },
      { name: "Provider 2", accreditation_id: "5610" },
      { name: "Provider 3", accreditation_id: "5660" },
      { name: "Provider 4", accreditation_id: "5697" },
    ]

    providers_data.each do |provider_data|
      create(:provider, provider_data)
    end
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
    attach_file("system_admin_funding_upload_form[file]", Rails.root.join("spec/support/fixtures/#{funding_type.pluralize}.csv"))
    submit_form
  end

  def when_i_submit_invalid_funding_upload_data = submit_form

  def submit_form = click_on("Upload the file")

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(funding_uploads_confirmation_path)
  end

  def and_i_return_to_the_funding_uploads_page
    then_i_see_the_confirmation_page
    click_on("Upload more funding information")
    expect(page).to have_current_path("/system-admin/funding-uploads")
  end

  def then_i_see_the_funding_upload_details_for(funding_type)
    within("##{funding_type}") do
      expect(page).to have_content("January")
      expect(page).to have_content(SystemAdmin::FundingUpload.last.created_at.strftime("%d %B %Y"))
    end
  end

  def then_i_see_the_errors
    expect(page).to have_content("Select month")
    expect(page).to have_content("Select a CSV file")
  end
end
