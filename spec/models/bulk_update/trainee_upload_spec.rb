# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUpload do
  it { is_expected.to belong_to(:provider) }
  it { is_expected.to have_many(:trainee_upload_rows).dependent(:destroy) }

  it do
    expect(subject).to define_enum_for(:status)
      .without_instance_methods.with_values(
        pending: "pending",
        validated: "validated",
        in_progress: "in_progress",
        succeeded: "succeeded",
        failed: "failed",
        cancelled: "cancelled",
      ).backed_by_column_of_type(:string)
  end

  describe "events" do
    subject { create(:bulk_update_trainee_upload) }

    describe "#process!" do
      it "sets the status to validated" do
        expect {
          subject.process!
        }.to change(subject, :status).from("pending").to("validated")
      end
    end

    describe "#submit!" do
      let(:current_time) { Time.current }

      before do
        subject.process!
      end

      it "sets the status to in_progress and the submitted_at to Time.current" do
        Timecop.freeze(current_time) do
          expect {
            subject.submit!
          }.to change(subject, :status).from("validated").to("in_progress")
            .and change(subject, :submitted_at).from(nil).to(current_time)
        end
      end
    end

    describe "#succeed!" do
      before do
        subject.process!
        subject.submit!
      end

      it "sets the status to succeeded" do
        expect {
          subject.succeed!
        }.to change(subject, :status).from("in_progress").to("succeeded")
      end
    end

    describe "#fail!" do
      context "when the status is 'pending'" do
        it "sets the status to failed" do
          expect {
            subject.fail!
          }.to change(subject, :status).from("pending").to("failed")
        end
      end

      context "when the status is 'validated'" do
        before do
          subject.process!
        end

        it "sets the status to failed" do
          expect {
            subject.fail!
          }.to change(subject, :status).from("validated").to("failed")
        end
      end

      context "when the status is 'in_progress'" do
        before do
          subject.process!
          subject.submit!
        end

        it "sets the status to failed" do
          expect {
            subject.fail!
          }.to change(subject, :status).from("in_progress").to("failed")
        end
      end
    end
  end

  describe "#total_rows_with_errors" do
    subject(:trainee_upload) { create(:bulk_update_trainee_upload) }

    let!(:rows_with_validation_errors) do
      create_list(
        :bulk_update_trainee_upload_row,
        2,
        :with_multiple_errors,
        trainee_upload: trainee_upload,
        error_type: :validation,
      )
    end
    let!(:rows_with_duplicate_errors) do
      create_list(
        :bulk_update_trainee_upload_row,
        2,
        :with_errors,
        trainee_upload: trainee_upload,
        error_type: :duplicate,
      )
    end
    let!(:rows_without_errors) do
      create_list(:bulk_update_trainee_upload_row, 2, trainee_upload:)
    end

    it "returns the correct number of rows with errors" do
      expect(trainee_upload.total_rows_with_errors).to eq(4)
    end
  end
end
