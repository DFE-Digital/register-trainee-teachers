# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_uploads
#
#  id           :bigint           not null, primary key
#  csv_data     :text
#  funding_type :integer
#  month        :integer
#  status       :integer          default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_funding_uploads_on_funding_type  (funding_type)
#  index_funding_uploads_on_month         (month)
#  index_funding_uploads_on_status        (status)
#
module SystemAdmin
  class FundingUpload < ApplicationRecord
    enum :funding_type, {
      training_partner_trainee_summary: 0,
      training_partner_payment_schedule: 1,
      provider_trainee_summary: 2,
      provider_payment_schedule: 3,
    }

    enum :status, { pending: 0, processed: 1, failed: 2 }

    def self.recently_processed_upload_for(funding_type)
      where(funding_type: funding_type, status: :processed).order(created_at: :desc).first
    end
  end
end
