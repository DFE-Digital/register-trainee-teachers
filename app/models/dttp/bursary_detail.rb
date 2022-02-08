# frozen_string_literal: true

module Dttp
  class BursaryDetail < ApplicationRecord
    self.table_name = "dttp_bursary_details"

    validates :response, presence: true
  end
end
