# frozen_string_literal: true

module Api
  module Trainees
    class DestroyDegreeResponse
      include ServicePattern
      include Api::DegreeFundingCheckable

      def initialize(degree:, version:)
        @degree = degree
        @version = version
      end

      def call
        funding_check_klass.new(trainee: trainee, degrees: degrees_after_delete, version: version).errors.each do |error|
          degree.errors.add(:base, error.full_message)
        end

        if degree.errors.empty? && degree.destroy
          { json: { data: trainee_serializer_klass.new(trainee).as_hash }, status: :ok }
        else
          { json: { errors: degree.errors.full_messages }, status: :unprocessable_entity }
        end
      end

    private

      attr_reader :degree, :version

      delegate :trainee, to: :degree

      def degrees_after_delete
        ::Degree.where(trainee_id: trainee.id).reject { |saved_degree| saved_degree.id == degree.id }
      end

      def trainee_serializer_klass
        Api::GetVersionedItem.for_serializer(model: :trainee, version: version)
      end
    end
  end
end
