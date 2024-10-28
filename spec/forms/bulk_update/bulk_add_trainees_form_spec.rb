# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe BulkAddTraineesForm, type: :model do
    subject(:form) { described_class.new(provider:, file:) }

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

    context "when file is missing" do
      let(:file) { nil }

      it "returns validation errors and does not create a bulk_updates_trainee_upload record" do
        expect(form.valid?).to be false
        expect { form.save }.not_to change { BulkUpdate::TraineeUpload.count }
        expect(form.errors.messages[:file]).to include("Select a CSV file")
      end
    end

    context "when file is malformed" do
      let(:test_file_contents) { "trn,first_name,last_name\n0123456789,Bob,Roberts\"" }

      it "returns validation errors and does not create a bulk_updates_trainee_upload record" do
        expect(form.valid?).to be false
        expect { form.save }.not_to change { BulkUpdate::TraineeUpload.count }
        expect(form.errors.messages[:file]).to include("The selected file must be a CSV")
      end
    end

    context "when passed an empty file" do
      let(:test_file_contents) { "" }

      it "returns validation errors and does not create a bulk_updates_trainee_upload record" do
        expect(form.valid?).to be false
        expect { form.save }.not_to change { BulkUpdate::TraineeUpload.count }
        expect(form.errors.messages[:file]).to include("The selected file is empty")
      end
    end

    context "when passed file with just a header row" do
      let(:test_file_contents) { "trn,first_name,last_name" }

      it "returns validation errors and does not create a bulk_updates_trainee_upload record" do
        expect(form.valid?).to be false
        expect { form.save }.not_to change { BulkUpdate::TraineeUpload.count }
        expect(form.errors.messages[:file]).to include("The selected file must contain at least one trainee")
      end
    end

    context "when passed a valid file" do
      let(:test_file_contents) { "trn,first_name,last_name\n0123456789,Bob,Roberts" }

      it "returns no validation errors and creates a BulkUpdate::TraineeUpload record" do
        expect(form.valid?).to be true
        expect { form.save }.to change { BulkUpdate::TraineeUpload.count }.by(1)
        expect(form.errors).to be_empty
      end
    end
  end
end
