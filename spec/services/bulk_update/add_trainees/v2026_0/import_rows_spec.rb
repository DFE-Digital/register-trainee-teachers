# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::AddTrainees::V20260::ImportRows do
  before do
    stub_const("BulkUpdate::AddTrainees::Config::VERSION", "v2026.0")
    stub_const("BulkUpdate::AddTrainees::VERSION", BulkUpdate::AddTrainees::V20260)
    allow(Settings.bulk_update.add_trainees).to receive(:version).and_return("v2026.0")
  end

  describe "#call" do
    let!(:nationality) { create(:nationality, :british) }
    let!(:academic_cycle) { create(:academic_cycle, :current) }

    context "when the feature flag is off", feature_bulk_add_trainees: false do
      let(:trainee_upload) { create(:bulk_update_trainee_upload) }

      it "does not call the `ImportRow` service" do
        allow(BulkUpdate::AddTrainees::V20260::ImportRow).to receive(:call)

        described_class.call(trainee_upload)

        expect(BulkUpdate::AddTrainees::V20260::ImportRow).not_to have_received(:call)
      end
    end

    context "when the feature flag is on", feature_bulk_add_trainees: true do
      before { @original_trainee_count = Trainee.count }

      context "when all rows are valid and can be imported" do
        context "when the upload status is pending" do
          let(:trainee_upload) { create(:bulk_update_trainee_upload, :pending) }

          it "does not create any trainee records" do
            allow(BulkUpdate::AddTrainees::V20260::ImportRow).to receive(:call).and_call_original

            expect(described_class.call(trainee_upload)).to be(true)
            expect(BulkUpdate::AddTrainees::V20260::ImportRow).to have_received(:call).exactly(5).times
          end

          it "creates bulk_update_trainee_upload_rows records" do
            expect {
              described_class.call(trainee_upload)
            }.to change { BulkUpdate::TraineeUploadRow.count }.by(5)
          end

          it "sets the status to `validated`" do
            described_class.call(trainee_upload)

            expect(trainee_upload.reload).to be_validated
          end

          it "does not submit for TRN" do
            allow(Trainees::SubmitForTrn).to receive(:call)

            described_class.call(trainee_upload)

            expect(Trainees::SubmitForTrn).not_to have_received(:call)
          end

          context "when there is a database error" do
            before do
              allow(BulkUpdate::TraineeUploadRow).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError)
              allow(Trainees::SubmitForTrn).to receive(:call)
            end

            it "raises the exception and sets the status to `failed`" do
              expect { described_class.call(trainee_upload) }.to raise_error(ActiveRecord::ActiveRecordError)
              expect(trainee_upload.reload).to be_failed
              expect(Trainees::SubmitForTrn).not_to have_received(:call)
            end
          end
        end

        context "when the upload status is in progress" do
          let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_rows, status: :in_progress) }

          it "creates 5 trainee records" do
            allow(BulkUpdate::AddTrainees::V20260::ImportRow).to receive(:call).and_call_original
            allow(Trainees::SubmitForTrn).to receive(:call).and_call_original

            expect(described_class.call(trainee_upload)).to be(true)

            expect(BulkUpdate::AddTrainees::V20260::ImportRow).to have_received(:call).exactly(5).times
            expect(Trainees::SubmitForTrn).to have_received(:call).exactly(5).times
          end

          it "sets the status to `succeeded`" do
            described_class.call(trainee_upload)
            expect(trainee_upload.reload).to be_succeeded
          end

          context "when there is a database error" do
            before do
              allow(Trainees::SubmitForTrn).to receive(:call).and_call_original
              allow(BulkUpdate::AddTrainees::V20260::ImportRow).to receive(:call).and_raise(ActiveRecord::ActiveRecordError)
            end

            it "sets the status to `failed`" do
              described_class.call(trainee_upload)

              expect(trainee_upload.reload).to be_failed
              expect(Trainees::SubmitForTrn).not_to have_received(:call)
            end

            it "sends the exception to Sentry" do
              allow(Sentry).to receive(:capture_exception)

              described_class.call(trainee_upload)

              expect(Sentry).to have_received(:capture_exception).exactly(5).times.with(
                an_instance_of(ActiveRecord::ActiveRecordError),
                extra: {
                  provider_id: trainee_upload.provider_id,
                  user_id: trainee_upload.submitted_by_id,
                },
              )
            end
          end
        end
      end

      context "when some rows are valid and can be imported and some rows are blank" do
        context "when the upload status is pending" do
          let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_blank_rows, :pending) }

          it "does not create any trainee records" do
            allow(BulkUpdate::AddTrainees::V20260::ImportRow).to receive(:call).and_call_original

            expect(described_class.call(trainee_upload)).to be(true)

            expect(BulkUpdate::AddTrainees::V20260::ImportRow).to have_received(:call).exactly(3).times
          end

          it "creates bulk_update_trainee_upload_rows records" do
            expect {
              described_class.call(trainee_upload)
            }.to change { BulkUpdate::TraineeUploadRow.count }.by(3)
          end

          it "sets the status to `validated`" do
            described_class.call(trainee_upload)

            expect(trainee_upload.reload).to be_validated
          end

          it "does not submit for TRN" do
            allow(Trainees::SubmitForTrn).to receive(:call)

            described_class.call(trainee_upload)

            expect(Trainees::SubmitForTrn).not_to have_received(:call)
          end
        end
      end

      context "when rows are valid but some headers have incorrect casing" do
        context "when the upload status is pending" do
          let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_mixed_case_headers, :pending) }

          it "does not create any trainee records" do
            allow(BulkUpdate::AddTrainees::V20260::ImportRow).to receive(:call).and_call_original

            expect(described_class.call(trainee_upload)).to be(true)

            expect(BulkUpdate::AddTrainees::V20260::ImportRow).to have_received(:call).exactly(5).times
          end

          it "creates bulk_update_trainee_upload_rows records" do
            expect {
              described_class.call(trainee_upload)
            }.to change { BulkUpdate::TraineeUploadRow.count }.by(5)
          end

          it "converts rows to standard case" do
            described_class.call(trainee_upload)
            first_row = BulkUpdate::TraineeUploadRow.first
            expect(first_row.data["First Names"]).to eq("Spencer")
            expect(first_row.data["Last Name"]).to eq("Murphy")
            expect(first_row.data["Email"]).to eq("Spencer.Murphy@example.com")
          end

          it "sets the status to `validated`" do
            described_class.call(trainee_upload)
            expect(trainee_upload.reload).to be_validated
          end
        end
      end

      context "when some rows are valid and can be imported whilst others are not" do
        let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_errors) }

        before do
          trainee_upload.import!

          allow(BulkUpdate::AddTrainees::V20260::ImportRow).to receive(:call).and_return(
            BulkUpdate::AddTrainees::V20260::ImportRow::Result.new({}, true, []),
            BulkUpdate::AddTrainees::V20260::ImportRow::Result.new({}, true, []),
            BulkUpdate::AddTrainees::V20260::ImportRow::Result.new(
              nil,
              false,
              { errors: { funding: ["Funding type is required"], email: "Enter an email address" } },
            ),
            BulkUpdate::AddTrainees::V20260::ImportRow::Result.new({}, true, []),
            BulkUpdate::AddTrainees::V20260::ImportRow::Result.new(
              nil,
              false,
              ["Add at least one degree"],
            ),
          )
        end

        it "does not create any trainee records" do
          expect(described_class.call(trainee_upload)).to be(false)
          expect(Trainee.count).to eq(@original_trainee_count)
          expect(BulkUpdate::AddTrainees::V20260::ImportRow).to have_received(:call).exactly(5).times
        end

        it "sets the status to `failed`" do
          described_class.call(trainee_upload)
          expect(trainee_upload.reload).to be_failed
        end

        it "creates an error record for the failing row" do
          expect { described_class.call(trainee_upload) }.to(
            change { BulkUpdate::RowError.count }.by(3),
          )
          expect(
            trainee_upload.trainee_upload_rows[2].row_errors.pluck(:message),
          ).to eq(["Funding type is required", "Enter an email address"])
          expect(
            trainee_upload.trainee_upload_rows[4].row_errors.pluck(:message),
          ).to eq(["Add at least one degree"])
        end
      end

      context "when some rows cause an exception in the API service classes" do
        let(:trainee_upload) { create(:bulk_update_trainee_upload, :pending) }

        before do
          allow(BulkUpdate::AddTrainees::V20260::ImportRow).to receive(:call).and_raise(StandardError.new("Server on fire"))
        end

        it "sets the status to `failed`" do
          described_class.call(trainee_upload)
          expect(trainee_upload.reload).to be_failed
        end

        it "creates an error record for the failing row" do
          expect { described_class.call(trainee_upload) }.to(
            change { BulkUpdate::RowError.count }.by(5),
          )
          expect(
            trainee_upload.trainee_upload_rows[0].row_errors.pluck(:message),
          ).to eq(["runtime failure: Server on fire"])
        end
      end
    end
  end

  describe "documentation cross-checks" do
    let(:documentation_fields) { YAML.load_file(BulkUpdate::AddTrainees::V20260::ImportRows.fields_definition_path) }

    BulkUpdate::AddTrainees::V20260::ImportRows::TRAINEE_HEADERS.each_value do |id|
      it "documents field with id #{id}" do
        expect(documentation_fields.map { |field| field["technical"] }).to include(id)
      end
    end

    BulkUpdate::AddTrainees::V20260::ImportRows::TRAINEE_HEADERS.each_key do |name|
      it "documents field with name #{name}" do
        expect(documentation_fields.map { |field| field["field_name"] }).to include(name)
      end
    end
  end

  describe "template CSV cross-checks" do
    let(:file_path) { Rails.public_path.join("csv/v2026_0/bulk_create_trainee.csv") }
    let(:headers) { CSVSafe.new(File.open(file_path), headers: true, encoding: "UTF-8").read.headers }

    BulkUpdate::AddTrainees::V20260::ImportRows::ALL_HEADERS.each_key do |name|
      it "includes column header #{name}" do
        expect(headers).to include(name)
      end
    end
  end
end
