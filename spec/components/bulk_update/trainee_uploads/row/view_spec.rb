# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploads::Row::View, type: :component do
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
        "pending" => "Pending",
        "validated" => "Validated",
        "in_progress" => "In progress",
        "succeeded" => "Succeeded",
        "failed" => "Failed",
        "cancelled" => "Cancelled",
      }.with_indifferent_access
    end

    %w[pending validated in_progress succeeded failed cancelled].each do |status|
      context "when #{status}" do
        let(:upload) { build(:bulk_update_trainee_upload, status) }

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

  describe "#submitted_at" do
    context "when bulk_update_trainee_upload#submitted_at is nil" do
      let(:upload) { build(:bulk_update_trainee_upload) }

      it do
        expect(subject.submitted_at).to be_nil
      end
    end

    context "when bulk_update_trainee_upload#submitted_at is not nil" do
      let(:submitted_at) { Time.current }
      let(:upload) { build(:bulk_update_trainee_upload, submitted_at:) }

      it do
        expect(subject.submitted_at).to eq(submitted_at.to_fs(:govuk_date_and_time))
      end
    end
  end
end
