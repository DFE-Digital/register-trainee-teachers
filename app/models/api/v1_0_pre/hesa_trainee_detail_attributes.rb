# frozen_string_literal: true

module Api
  module V10Pre
    class HesaTraineeDetailAttributes < Api::V01::HesaTraineeDetailAttributes
      include Api::ErrorAttributeAdapter
    end
  end
end
