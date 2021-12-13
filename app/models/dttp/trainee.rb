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
               class_name: "::Trainee"

    belongs_to :provider,
               class_name: "::Provider",
               foreign_key: :provider_dttp_id,
               primary_key: :dttp_id,
               inverse_of: :dttp_trainees,
               optional: true

    validates :response, presence: true

    enum state: {
      importable: 0,
      imported: 1,
      non_importable_duplicate: 2,
      non_importable_missing_route: 3,
      non_importable_hpitt: 4,
      non_importable_missing_state: 5,
    }

    def date_of_birth
      return if response["birthdate"].blank?

      Date.parse(response["birthdate"])
    end
  end
end
