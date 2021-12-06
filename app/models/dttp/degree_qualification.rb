# frozen_string_literal: true

module Dttp
  class DegreeQualification < ApplicationRecord
    self.table_name = "dttp_degree_qualifications"

    belongs_to :trainee,
               foreign_key: :contact_dttp_id,
               primary_key: :dttp_id,
               optional: true,
               inverse_of: :degree_qualifications

    validates :response, presence: true

    enum state: {
      unprocessed: 0,
    }

    def country_id
      response["_dfe_degreecountryid_value"]
    end
  end
end
