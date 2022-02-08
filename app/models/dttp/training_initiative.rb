# frozen_string_literal: true

module Dttp
  class TrainingInitiative < ApplicationRecord
    self.table_name = "dttp_training_initiatives"

    validates :response, presence: true
  end
end
