# frozen_string_literal: true

module Api
  module Trainees
    class SaveDegreeResponse
      include ServicePattern
      include Api::Attributable
      include Api::Serializable
      include Api::ErrorResponse

      def initialize(degree:, params:, version:)
        @degree = degree
        @params = params
        @version = version
        @status = new_record? ? :created : :ok
      end

      def call
        if save
          update_progress
          { json: { data: serializer_klass.new(degree).as_hash }, status: status }
        elsif duplicates?
          conflict_errors_response(errors:)
        else
          validation_errors_response(errors:)
        end
      end

      delegate :assign_attributes, :new_record?, :trainee, to: :degree
      delegate :valid?, :attributes, :duplicates?, to: :degree_attributes
      delegate :degrees, to: :trainee

    private

      attr_reader :degree, :params, :version, :status

      def save
        assign_attributes(attributes)

        if valid? && degree.save
          true
        else
          false
        end
      end

      def update_progress
        if degrees.present?
          trainee.progress[:degrees] = true
          trainee.save!
        end
      end

      def model = :degree

      def degree_attributes
        @degree_attributes ||=
          if new_record?
            attributes_klass.new(params, trainee:)
          else
            attributes = attributes_klass.from_degree(degree, trainee:)
            attributes.assign_attributes(params)
            attributes
          end
      end

      def errors = degree_attributes.errors || degree.errors
    end
  end
end
