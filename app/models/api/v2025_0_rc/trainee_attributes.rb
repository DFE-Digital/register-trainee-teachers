# frozen_string_literal: true

module Api
  module V20250Rc
    class TraineeAttributes < Api::V01::TraineeAttributes
      include Api::ErrorAttributeAdapter

      validate :course_subject_two_valid, if: :require_subject?
      validate :course_subject_three_valid, if: :require_subject?
      validate :itt_end_date_valid

      validates :provider_trainee_id, length: { maximum: 50 }

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
          self.hesa_trainee_detail_attributes = V20250Rc::HesaTraineeDetailAttributes.new(
            new_hesa_trainee_detail_attributes.merge(trainee_attributes: self),
            record_source:,
          )
        end

        self.trainee_disabilities_attributes = []

        new_attributes[:disabilities]&.each do |disability|
          trainee_disabilities_attributes << { disability_id: disability.id }
        end
      end

    private

      def require_subject?
        EARLY_YEARS_TRAINING_ROUTES.exclude?(training_route)
      end

      def course_subject_two_valid
        return if course_subject_two.nil?

        errors.add(:course_subject_two, :duplicate) if course_subject_one == course_subject_two
      end

      def course_subject_three_valid
        return if course_subject_three.nil?

        errors.add(:course_subject_three, :duplicate) if [course_subject_one, course_subject_two].include?(course_subject_three)
      end

      def itt_end_date_valid
        return if !valid_date_string?(itt_start_date) || !valid_date_string?(itt_end_date)

        parsed_itt_start_date = itt_start_date.is_a?(String) ? Date.iso8601(itt_start_date) : itt_start_date
        parsed_itt_end_date   = itt_end_date.is_a?(String) ? Date.iso8601(itt_end_date) : itt_end_date

        errors.add(:itt_end_date, :before_or_same_as_start_date) if parsed_itt_start_date >= parsed_itt_end_date
      end
    end
  end
end
