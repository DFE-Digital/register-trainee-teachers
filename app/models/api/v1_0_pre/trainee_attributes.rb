# frozen_string_literal: true

module Api
  module V10Pre
    class TraineeAttributes < Api::V01::TraineeAttributes
      include Api::ErrorAttributeAdapter
    end
  end
end
