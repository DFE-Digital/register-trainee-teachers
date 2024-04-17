# frozen_string_literal: true

module Api
  module TraineeDisabilityAttributes
    class V01
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :disability_id, :integer

      def initialize(disability)
        super({})

        if disability
          self.disability_id = disability.id
        else
          errors.add(:disability_id, "No disability provided")
        end
      end
    end
  end
end
