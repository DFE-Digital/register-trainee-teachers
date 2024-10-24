# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_trainee_uploads
#
#  id                 :bigint           not null, primary key
#  file               :text
#  file_name          :string
#  number_of_trainees :integer
#  status             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  provider_id        :bigint           not null
#  error_messages     :jsonb
#
# Indexes
#
#  index_bulk_update_trainee_uploads_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)

class BulkUpdate::TraineeUpload < ApplicationRecord
  belongs_to :provider

  enum :status, {
    pending: "pending",
    validated: "validated",
    submitted: "submitted",
    succeeded: "succeeded",
    failed: "failed",
  }
end
