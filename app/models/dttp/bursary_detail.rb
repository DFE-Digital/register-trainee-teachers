# frozen_string_literal: true

# == Schema Information
#
# Table name: dttp_bursary_details
#
#  id         :bigint           not null, primary key
#  response   :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  dttp_id    :uuid             not null
#
# Indexes
#
#  index_dttp_bursary_details_on_dttp_id  (dttp_id) UNIQUE
#
module Dttp
  class BursaryDetail < ApplicationRecord
    self.table_name = "dttp_bursary_details"

    validates :response, presence: true
  end
end
