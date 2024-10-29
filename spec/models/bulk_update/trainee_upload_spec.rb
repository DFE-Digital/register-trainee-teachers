# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUpload do
  it { is_expected.to belong_to(:provider) }
  it { is_expected.to have_many(:bulk_update_trainee_upload_rows).dependent(:destroy) }
end
