# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUpload do
  it { is_expected.to belong_to(:provider) }
  it { is_expected.to have_many(:trainee_upload_rows).dependent(:destroy) }

  it do
    expect(subject).to define_enum_for(:status).with_values(
      pending: "pending",
      validated: "validated",
      submitted: "submitted",
      succeeded: "succeeded",
      failed: "failed",
      cancelled: "cancelled",
    ).backed_by_column_of_type(:string)
  end
end
