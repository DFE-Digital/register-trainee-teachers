# frozen_string_literal: true

module Dqt
  class TrnRequest < ApplicationRecord
    self.table_name = "dqt_trn_requests"

    belongs_to :trainee

    enum state: {
      requested: 0,
      received: 1,
      failed: 2,
    }

    validates :request_id, :response, presence: true
  end
end
