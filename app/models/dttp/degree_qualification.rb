# frozen_string_literal: true

module Dttp
  class DegreeQualification < ApplicationRecord
    self.table_name = "dttp_degree_qualifications"

    validates :response, presence: true

    enum state: {
      unprocessed: 0,
    }
  end
end
