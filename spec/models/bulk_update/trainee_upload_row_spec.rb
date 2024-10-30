# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploadRow do
  it { is_expected.to belong_to(:trainee_upload) }
  it { is_expected.to have_many(:row_errors) }
end
