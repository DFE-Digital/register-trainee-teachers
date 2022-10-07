# frozen_string_literal: true

module Hesa
  class TrnSubmission < ApplicationRecord
    self.table_name = "hesa_trn_submissions"

    has_many :trainees

    def self.last_submitted_at
      order(:submitted_at)&.last&.submitted_at
    end
  end
end
