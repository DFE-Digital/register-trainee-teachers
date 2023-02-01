# frozen_string_literal: true

# == Schema Information
#
# Table name: hesa_trn_submissions
#
#  id           :bigint           not null, primary key
#  payload      :text
#  submitted_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
module Hesa
  class TrnSubmission < ApplicationRecord
    self.table_name = "hesa_trn_submissions"

    has_many :trainees

    def self.last_submitted_at
      order(:submitted_at)&.last&.submitted_at
    end
  end
end
