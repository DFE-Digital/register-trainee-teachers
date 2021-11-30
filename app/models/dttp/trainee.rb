# frozen_string_literal: true

module Dttp
  class Trainee < ApplicationRecord
    self.table_name = "dttp_trainees"

    CONTACT_TYPE_ID = "faba11c7-07d9-e711-80e1-005056ac45bb"

    validates :response, presence: true

    enum state: {
      unprocessed: 0,
    }
  end
end
