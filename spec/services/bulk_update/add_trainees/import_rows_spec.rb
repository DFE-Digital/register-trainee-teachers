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

                it "raises the exception and sets the status to `failed`" do
                  expect { described_class.call(trainee_upload) }.to raise_error(ActiveRecord::ActiveRecordError)
                  expect(trainee_upload.reload).to be_failed
                end
              end
            end
          end

          context "when some rows are valid and can be imported whilst others are not" do
            let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_errors) }

            it "does not create any trainee records" do
              expect(ImportRow).to receive(:call).exactly(5).times.and_call_original
              expect(described_class.call(trainee_upload)).to be(false)
              expect(Trainee.count).to eq(@original_trainee_count)
            end

            it "sets the status to `failed`" do
              described_class.call(trainee_upload)
              expect(trainee_upload.reload).to be_failed
            end
          end
        end
      end
    end
  end
end
