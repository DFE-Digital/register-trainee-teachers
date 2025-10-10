# frozen_string_literal: true

# == Schema Information
#
# Table name: dqt_trn_requests
#
#  id         :bigint           not null, primary key
#  response   :jsonb
#  state      :integer          default("requested")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  request_id :uuid             not null
#  trainee_id :bigint           not null
#
# Indexes
#
#  index_dqt_trn_requests_on_request_id  (request_id) UNIQUE
#  index_dqt_trn_requests_on_trainee_id  (trainee_id)
#
# Foreign Keys
#
#  fk_rails_...  (trainee_id => trainees.id)
#
module Dqt
  class TrnRequest < ApplicationRecord
    self.table_name = "dqt_trn_requests"

    belongs_to :trainee

    enum :state, {
      requested: 0,
      received: 1,
      failed: 2,
    }

    validates :request_id, presence: true

    def days_waiting
      (Date.current - created_at.to_date).to_i
    end
  end
end
