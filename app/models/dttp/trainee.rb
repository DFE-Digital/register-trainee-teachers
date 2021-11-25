# frozen_string_literal: true

module Dttp
  class Trainee < ApplicationRecord
    self.table_name = "dttp_trainees"

    CONTACT_TYPE_ID = "faba11c7-07d9-e711-80e1-005056ac45bb"

    enum state: {
      unprocessed: 0,
    }

    def provider_dttp_id
      # TODO should we expose the provider record here or the ID
      response["_parentcustomerid_value"]
    end

    def first_name
      response["firstname"]
    end

    def last_name
      response["lastname"]
    end

    def date_of_birth
      return unless response["birthdate"].present?

      Date.parse(response["birthdate"])
    end
  end
end
