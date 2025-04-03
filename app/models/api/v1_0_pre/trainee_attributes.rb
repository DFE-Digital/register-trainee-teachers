# frozen_string_literal: true

module Api
  module V10Pre
    class TraineeAttributes < Api::V01::TraineeAttributes
      include Api::ErrorAttributeAdapter

      def build_nested_models(new_attributes)
        new_attributes[:placements_attributes]&.each do |placement_params|
          placements_attributes << PlacementAttributes.new(placement_params, record_source:)
        end

        new_attributes[:degrees_attributes]&.each do |degree_params|
          degrees_attributes << DegreeAttributes.new(degree_params, record_source:)
        end

        new_attributes[:nationalisations_attributes]&.each do |nationalisation_params|
          nationalisations_attributes << NationalityAttributes.new(nationalisation_params)
        end

        new_hesa_trainee_detail_attributes = new_attributes.slice(*HesaTraineeDetailAttributes::ATTRIBUTES)
        if new_hesa_trainee_detail_attributes.present?
          self.hesa_trainee_detail_attributes = V10Pre::HesaTraineeDetailAttributes.new(new_hesa_trainee_detail_attributes, record_source:)
        end
      end
    end
  end
end
