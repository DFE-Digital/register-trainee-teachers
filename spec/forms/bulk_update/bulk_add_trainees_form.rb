# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe BulkAddTraineesForm, type: :model do
    subject(:form) { described_class.new(provider: provider, file: file) }

    let(:provider) { create(:provider) }
    let(:user) { create(:user) }
    let(:current_user) { UserWithOrganisationContext.new(user: user, session: {}) }

    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        {
          filename: "test.csv",
          tempfile: tempfile,
          type: content_type,
        },
      )
    end


    let(:tempfile) do
      t = Tempfile.new("test.csv")
      t.write(test_file_contents)
      t.rewind
      t
    end

    let(:content_type) { "text/csv" }

    context "when passed and empty file" do
      let(:test_file_contents) { "" }

      it "creates a bulk_updates_trainee_upload record and returns validation errors" do
        expect(form.valid?).to be false
        form.save
        # TODO: assert DB record
      end
    end

    context "when passed a valid file" do
      let(:test_file_contents) { "trn,first_name,last_name\n0123456789,Bob,Roberts" }

      it "returns a Placement record and CSV::Table" do
        expect(form.valid?).to be true
        form.save
        # TODO: assert DB record
      end
    end
  end
end

