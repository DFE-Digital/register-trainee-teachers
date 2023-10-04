# frozen_string_literal: true

require "rails_helper"

feature "Upload a file" do
  let(:user) { create(:user, :system_admin) }
  let(:index) { admin_uploads_page }
  let(:new_upload) { admin_upload_new_page }
  let(:show) { admin_upload_show_page }

  before do
    given_i_am_authenticated(user:)
    when_i_visit_the_uploads_index_page
    and_i_click_on_upload_file
  end

  describe "Uploading a file" do
    scenario "without attaching a file" do
      and_i_click_on_submit
      then_i_see_an_error
    end

    scenario "with required attributes and a clean file" do
      attach_file("upload[file]", Rails.root.join("spec/fixtures/files/test.csv"))
      and_i_click_on_submit
      and_file_scan_result_is("clean")
      then_i_see_the_upload
    end

    scenario "with required attributes and a pending file" do
      attach_file("upload[file]", Rails.root.join("spec/fixtures/files/test.csv"))
      and_i_click_on_submit
      then_i_see_the_upload_without_a_download_link
    end

    scenario "with required attributes and a suspect file" do
      attach_file("upload[file]", Rails.root.join("spec/fixtures/files/test.csv"))
      and_i_click_on_submit
      and_file_scan_result_is("suspect")
      then_i_see_the_upload_without_a_download_link
    end
  end

private

  def when_i_visit_the_uploads_index_page
    index.load
  end

  def and_i_click_on_upload_file
    index.upload_file.click
  end

  def and_i_click_on_submit
    new_upload.submit.click
  end

  def and_file_scan_result_is(malware_scan_result)
    current_url = show.current_url
    id = current_url.split("/").last
    upload = Upload.find(id)
    upload.update!(malware_scan_result:)
    show.load(id:)
  end

  def then_i_see_the_upload
    expect(show).to have_text("test.csv")
    expect(show).not_to have_text("Upload has not yet been flagged as clean")
    expect(show).not_to have_text("File pending approval")
  end

  def then_i_see_the_upload_without_a_download_link
    expect(show).not_to have_text("test.csv")
    expect(show).to have_text("File pending approval")
    expect(show).to have_text("Upload has not yet been flagged as clean")
  end

  def then_i_see_an_error
    expect(new_upload.error_summary).to be_visible
  end
end
