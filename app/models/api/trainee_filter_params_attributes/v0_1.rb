# frozen_string_literal: true

module Api
  module TraineeFilterParamsAttributes
    class V01
      include ActiveModel::Model
      include ActiveModel::Attributes

      ATTRIBUTES = %i[status since academic_cycle page per_page sort_order].freeze
      ATTRIBUTES.each { |attr| attribute attr }

      validate :check_statuses
      validate :check_since
      validate :check_academic_cycle
      validates :sort_order, inclusion: %w[desc asc], allow_blank: true

    private

      def check_statuses
        return if status.blank?

        (status.is_a?(Array) ? status : [status]).each do |status_value|
          errors.add(:status, "#{status_value} is not a valid status") unless TraineeFilter::STATUSES.include?(status_value)
        end
      end

      def check_since
        return if since.blank?

        errors.add(:since, "#{since} is not a valid date") unless iso8601?(since)
      end

      def check_academic_cycle
        return if academic_cycle.blank?

        unless AcademicCycle.for_year(academic_cycle)
          errors.add(
            :academic_cycle,
            "#{academic_cycle} is not a valid academic cycle year",
          )
        end
      end

      def iso8601?(string)
        DateTime.iso8601(string)
      rescue Date::Error
        false
      end
    end
  end
end
