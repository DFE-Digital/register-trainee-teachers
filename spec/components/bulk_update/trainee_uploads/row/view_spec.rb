# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploads::Row::View, type: :component do
  include Rails.application.routes.url_helpers

  subject { described_class.new(upload:) }

  describe "#status" do
    let(:colours) do
      {
        "pending" => "govuk-tag--light-blue",
        "validated" => "govuk-tag--turquoise",
        "in_progress" => "govuk-tag--blue",
        "succeeded" => "govuk-tag--green",
        "failed" => "govuk-tag--red",
        "cancelled" => "govuk-tag--yellow",
      }.with_indifferent_access
    end

    let(:statuses) do
      {
        "uploaded" => "Uploaded",
        "pending" => "Pending",
        "validated" => "Ready to submit",
        "in_progress" => "In progress",
        "succeeded" => "Trainees registered",
        "failed" => "Failed",
        "cancelled" => "Cancelled",
      }.with_indifferent_access
    end

    BulkUpdate::TraineeUpload.statuses.each_key do |status|
      context "when #{status}" do
        let(:upload) { create(:bulk_update_trainee_upload, status) }

        it do
          expect(
            render_inline(subject),
          ).to have_css(
            "span", class: "govuk-tag #{colours[upload.status]}", text: statuses[status]
          )
        end
      end
    end
  end

  describe "#upload_path" do
    context "when the upload is not 'cancelled'" do
      BulkUpdate::TraineeUpload.statuses.except(:cancelled).each_key do |status|
        context "when #{status}" do
          let(:upload) { create(:bulk_update_trainee_upload, status) }

          it do
            expect(
              render_inline(subject),
            ).to have_link(upload.created_at.to_fs(:govuk_date_and_time), href: upload_path(upload))
          end
        end
      end

      def upload_path(upload)
        {
          "uploaded" => bulk_update_add_trainees_upload_path(upload),
          "pending" => bulk_update_add_trainees_upload_path(upload),
          "validated" => bulk_update_add_trainees_upload_path(upload),
          "in_progress" => bulk_update_add_trainees_upload_path(upload),
          "succeeded" => bulk_update_add_trainees_upload_path(upload),
          "failed" => bulk_update_add_trainees_upload_path(upload),
        }.with_indifferent_access[upload.status]
      end
    end

    context "when the upload is 'cancelled'" do
      context "when cancelled" do
        let(:upload) { create(:bulk_update_trainee_upload, :cancelled) }

        it do
          expect(
            render_inline(subject),
          ).to have_text(upload.created_at.to_fs(:govuk_date_and_time))
        end
      end
    end
  end

  describe "#created_at" do
    let(:upload) { create(:bulk_update_trainee_upload) }

    it do
      expect(subject.created_at).to eq(upload.created_at.to_fs(:govuk_date_and_time))
    end
  end
end
