# frozen_string_literal: true

module Dttp
  class Trainee < ApplicationRecord
    self.table_name = "dttp_trainees"

    has_many :placement_assignments, foreign_key: :contact_dttp_id, primary_key: :dttp_id, inverse_of: :trainee
    has_many :degree_qualifications,
             foreign_key: :contact_dttp_id,
             primary_key: :dttp_id,
             inverse_of: :dttp_trainee

    belongs_to :trainee,
               foreign_key: :dttp_id,
               primary_key: :dttp_id,
               inverse_of: :dttp_trainee,
               optional: true,
               class_name: "Trainee"

    validates :response, presence: true

    enum state: {
      unprocessed: 0,
      non_processable_duplicate: 1,
      processed: 2,
    }

    def provider_dttp_id
      # TODO: should we expose the provider record here or the ID
      response["_parentcustomerid_value"]
    end

    def date_of_birth
      return if response["birthdate"].blank?

      Date.parse(response["birthdate"])
    end
  end
end
