# frozen_string_literal: true

require "rails_helper"

feature "Delete a file" do
  let!(:user) { create(:user, :system_admin) }
  let!(:upload) { create(:upload) }

  let(:index) { admin_uploads_page }
  let(:new_upload) { admin_upload_new_page }
  let(:show) { admin_upload_show_page }

  before do
    given_i_am_authenticated(user:)
    when_i_visit_the_uploads_index_page
  end

  describe "Deleting an upload" do
    scenario "upload can be deleted" do
      and_an_upload_exists
      and_i_delete_the_upload
      then_the_upload_no_longer_shows
    end
  end

private

  def when_i_visit_the_uploads_index_page
    index.load
  end

  def and_an_upload_exists
    show.load(id: upload.id)
    expect(show).to have_text "test.csv"
  end

  def and_i_delete_the_upload
    show.delete_upload.click
  end

  def then_the_upload_no_longer_shows
    expect(index).not_to have_text "test.csv"
  end
end
