# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module AddTrainees
    RSpec.describe ImportRows do
      describe "#call" do
        let!(:nationality) { create(:nationality, :british) }

        context "when the feature flag is off", feature_bulk_add_trainees: false do
          let(:trainee_upload) { create(:bulk_update_trainee_upload) }

          it "does not call the `ImportRow` service" do
            expect(ImportRow).not_to receive(:call)
            described_class.call(trainee_upload)
          end
        end

        context "when the feature flag is on", feature_bulk_add_trainees: true do
          before { @original_trainee_count = Trainee.count }

          context "when all rows are valid and can be imported" do
            context "when the upload status is pending" do
              let(:trainee_upload) { create(:bulk_update_trainee_upload, :pending) }

              before do
                allow(ImportRow).to receive(:call).and_return(
                  BulkUpdate::AddTrainees::ImportRow::Result.new(true, []),
                )
              end

              it "does not create any trainee records" do
                expect(ImportRow).to receive(:call).exactly(5).times.and_call_original
                expect(described_class.call(trainee_upload)).to be(true)
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

              context "when there is a database error" do
                before { allow(BulkUpdate::TraineeUploadRow).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError) }

                it "raises the exception and sets the status to `failed`" do
                  expect { described_class.call(trainee_upload) }.to raise_error(ActiveRecord::ActiveRecordError)
                  expect(trainee_upload.reload).to be_failed
                end
              end
            end

            context "when the upload status is in progress" do
              let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_rows, status: :in_progress) }

              before do
                allow(ImportRow).to receive(:call).and_return(
                  BulkUpdate::AddTrainees::ImportRow::Result.new(true, []),
                )
              end

              it "creates 5 trainee records" do
                expect(ImportRow).to receive(:call).exactly(5).times.and_call_original
                expect(described_class.call(trainee_upload)).to be(true)
              end

              it "sets the status to `succeeded`" do
                described_class.call(trainee_upload)
                expect(trainee_upload.reload).to be_succeeded
              end

              context "when there is a database error" do
                before { allow(BulkUpdate::AddTrainees::ImportRow).to receive(:call).and_raise(ActiveRecord::ActiveRecordError) }

                it "sets the status to `failed`" do
                  described_class.call(trainee_upload)
                  expect(trainee_upload.reload).to be_failed
                end

                it "sends the exception to Sentry" do
                  expect(Sentry).to receive(:capture_exception).at_least(5).times.with(
                    an_instance_of(ActiveRecord::ActiveRecordError),
                    extra: {
                      provider_id: trainee_upload.provider_id,
                      user_id: trainee_upload.submitted_by_id,
                    },
                  )
                  described_class.call(trainee_upload)
                end
              end
            end
          end

          context "when some rows are valid and can be imported and some rows are blank" do
            context "when the upload status is pending" do
              let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_blank_rows, :pending) }

              before do
                allow(ImportRow).to receive(:call).and_return(
                  BulkUpdate::AddTrainees::ImportRow::Result.new(true, []),
                )
              end

              it "does not create any trainee records" do
                expect(ImportRow).to receive(:call).exactly(3).times.and_call_original
                expect(described_class.call(trainee_upload)).to be(true)
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
            end
          end

          context "when some rows are valid and can be imported whilst others are not" do
            let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_errors) }

            before do
              trainee_upload.import!

              allow(ImportRow).to receive(:call).and_return(
                BulkUpdate::AddTrainees::ImportRow::Result.new(true, []),
                BulkUpdate::AddTrainees::ImportRow::Result.new(true, []),
                BulkUpdate::AddTrainees::ImportRow::Result.new(
                  false,
                  { errors: { funding: ["Funding type is required"], email: "Enter an email address" } },
                ),
                BulkUpdate::AddTrainees::ImportRow::Result.new(true, []),
                BulkUpdate::AddTrainees::ImportRow::Result.new(
                  false,
                  ["Add at least one degree"],
                ),
              )
            end

            it "does not create any trainee records" do
              expect(ImportRow).to receive(:call).exactly(5).times.and_call_original
              expect(described_class.call(trainee_upload)).to be(false)
              expect(Trainee.count).to eq(@original_trainee_count)
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
              allow(ImportRow).to receive(:call).and_raise(StandardError.new("Server on fire"))
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
        let(:documentation_fields) { YAML.load_file(CsvFields::View::FIELD_DEFINITION_PATH) }

        BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS.each_value do |id|
          it "documents field with id #{id}" do
            expect(documentation_fields.map { |field| field["technical"] }).to include(id)
          end
        end

        BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS.each_key do |name|
          it "documents field with name #{name}" do
            expect(documentation_fields.map { |field| field["field_name"] }).to include(name)
          end
        end
      end

      describe "template CSV cross-checks" do
        let(:file_path) { Rails.public_path.join("csv/bulk_create_trainee.csv") }
        let(:headers) { CSVSafe.new(File.open(file_path), headers: true, encoding: "UTF-8").read.headers }

        BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.each_key do |name|
          it "includes column header #{name}" do
            expect(headers).to include(name)
          end
        end
      end
    end
  end
end
