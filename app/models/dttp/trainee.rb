# frozen_string_literal: true

module Dttp
  class Trainee < ApplicationRecord
    self.table_name = "dttp_trainees"

    has_many :placement_assignments, foreign_key: :contact_dttp_id, primary_key: :dttp_id, inverse_of: :trainee

    belongs_to :provider, class_name: "::Provider", foreign_key: :provider_dttp_id, primary_key: :dttp_id, inverse_of: :dttp_trainees, optional: true

    validates :response, presence: true

    enum state: {
      unprocessed: 0,
      non_processable_duplicate: 1,
      non_processable_missing_route: 2,
      processed: 3,
    }

    def date_of_birth
      return if response["birthdate"].blank?

      Date.parse(response["birthdate"])
    end
  end
end
