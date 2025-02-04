# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUpload do
  it { is_expected.to belong_to(:provider) }
  it { is_expected.to belong_to(:submitted_by).class_name("User").optional }
  it { is_expected.to have_many(:trainee_upload_rows).dependent(:destroy) }

  it do
    expect(subject).to define_enum_for(:status)
      .without_instance_methods.with_values(
        uploaded: "uploaded",
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

    let!(:user) { create(:user) }

    before do
      Current.user = user
    end

    after do
      Current.user = nil
    end

    describe "#import!" do
      it do
        expect {
          subject.import!
        }.to change(subject, :status).from("uploaded").to("pending")
      end
    end

    describe "#process!" do
      before do
        subject.import!
      end

      it do
        expect {
          subject.process!
        }.to change(subject, :status).from("pending").to("validated")
      end
    end

    describe "#submit!" do
      let!(:current_time) { Time.current.round }

      before do
        subject.import!
        subject.process!

        Timecop.freeze(current_time)
      end

      after do
        Timecop.return
      end

      it do
        expect {
          subject.submit!
        }.to change(subject, :status).from("validated").to("in_progress")
          .and change(subject, :submitted_by).from(nil).to(user)
          .and change(subject, :submitted_at).from(nil).to(current_time)
      end
    end

    describe "#succeed!" do
      before do
        subject.import!
        subject.process!
        subject.submit!
      end

      it do
        expect {
          subject.succeed!
        }.to change(subject, :status).from("in_progress").to("succeeded")
      end
    end

    describe "#cancel!" do
      context "when the status is 'uploaded'" do
        it do
          expect {
            subject.cancel!
          }.to change(subject, :status).from("uploaded").to("cancelled")
        end
      end

      context "when the status is 'validated'" do
        before do
          subject.import!
          subject.process!
        end

        it do
          expect {
            subject.cancel!
          }.to change(subject, :status).from("validated").to("cancelled")
        end
      end

      context "when the status is 'failed'" do
        before do
          subject.import!
          subject.process!
          subject.fail!
        end

        it do
          expect {
            subject.cancel!
          }.to change(subject, :status).from("failed").to("cancelled")
        end
      end
    end

    describe "#fail!" do
      context "when the status is 'pending'" do
        before do
          subject.import!
        end

        it do
          expect {
            subject.fail!
          }.to change(subject, :status).from("pending").to("failed")
        end
      end

      context "when the status is 'validated'" do
        before do
          subject.import!
          subject.process!
        end

        it do
          expect {
            subject.fail!
          }.to change(subject, :status).from("validated").to("failed")
        end
      end

      context "when the status is 'in_progress'" do
        before do
          subject.import!
          subject.process!
          subject.submit!
        end

        it do
          expect {
            subject.fail!
          }.to change(subject, :status).from("in_progress").to("failed")
        end
      end
    end
  end

  describe "scopes" do
    describe "#current_academic_cycle" do
      let(:previous_academic_cycle) { create(:academic_cycle, previous_cycle: true) }
      let(:current_academic_cycle) { create(:academic_cycle, :current) }
      let(:next_academic_cycle) { create(:academic_cycle, next_cycle: true) }

      let!(:previous_academic_cycle_upload) do
        create(
          :bulk_update_trainee_upload,
          created_at: rand(
            previous_academic_cycle.start_date..previous_academic_cycle.end_date,
          ),
        )
      end
      let!(:current_academic_cycle_upload) do
        create(
          :bulk_update_trainee_upload,
          created_at: rand(
            current_academic_cycle.start_date..current_academic_cycle.end_date,
          ),
        )
      end
      let!(:next_academic_cycle_upload) do
        create(
          :bulk_update_trainee_upload,
          created_at: rand(
            next_academic_cycle.start_date..next_academic_cycle.end_date,
          ),
        )
      end

      it "returns records from the current academic cycle" do
        expect(described_class.current_academic_cycle).to contain_exactly(current_academic_cycle_upload)
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
