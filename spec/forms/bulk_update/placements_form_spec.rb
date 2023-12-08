# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe PlacementsForm, type: :model do
    subject(:form) { described_class.new(provider: provider, file: file, user: current_user) }

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
      t.write(test_file.read)
      t.rewind
      t
    end

    let(:content_type) { "text/csv" }

    context "when passed a file" do
      before do
        allow(Placements::ValidateCsv).to receive(:new).with(anything).and_return(double("validation", validate!: true))
        allow(Placements::ValidateFile).to receive(:new).with(anything).and_return(double("validation", validate!: true))
      end

      context "that is a CSV with expected headers" do
        let(:test_file) { file_fixture("bulk_update/placements/complete.csv") }

        it "returns a Placement record and CSV::Table" do
          expect(form.valid?).to be true
          form.save
          expect(form.bulk_placement).to be_a BulkUpdate::Placement
          expect(form.csv).to be_a CSV::Table
        end
      end

      context "that has possibly malicious scripts" do
        let(:test_file) { file_fixture("bulk_update/placements/injected.csv") }

        it "returns a Placement record and sanitised CSV::Table" do
          # cell containing potential spreadsheet formula is safely quoted to avoid execution
          expect(form.csv["trn"][-1][0]).to eql "'"
          expect(form.valid?).to be true
          form.save
          expect(form.bulk_placement).to be_a BulkUpdate::Placement
          expect(form.csv).to be_a CSV::Table
        end
      end

      context "when saving" do
        let(:test_file) { file_fixture("bulk_update/placements/complete.csv") }

        it "calls Placements::CreatePlacementRows" do
          expect(Placements::CreatePlacementRows).to receive(:call)
            .with(bulk_placement: an_instance_of(BulkUpdate::Placement), csv: an_instance_of(CSV::Table))

          form.save
        end
      end

      context "when Placements::CreatePlacementRows raises ActiveRecord::StatementInvalid" do
        let(:test_file) { file_fixture("bulk_update/placements/complete.csv") }
        let(:mock_error) { ActiveRecord::StatementInvalid.new("Some DB error") }

        before do
          allow(Placements::CreatePlacementRows).to receive(:call).with(anything).and_raise(mock_error)
        end

        it "captures the exception with Sentry and handles the error" do
          expect(Sentry).to receive(:capture_exception)
            .with(mock_error, anything)

          expect(form.save).to be false

          expect(form.errors[:file]).to include(/There was an issue uploading your CSV file/)
          expect(form.bulk_placement).to be_nil
        end
      end
    end
  end
end
