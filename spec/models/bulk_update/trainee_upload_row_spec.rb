# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploadRow do
  it { is_expected.to belong_to(:bulk_update_trainee_upload) }
end
