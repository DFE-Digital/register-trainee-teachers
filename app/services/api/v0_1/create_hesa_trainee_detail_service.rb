# frozen_string_literal: true

module Api
  module V01
    class CreateHesaTraineeDetailService
      include ServicePattern

      def initialize(trainee:)
        @trainee = trainee
      end

      def call
        return true unless trainee.hesa_trainee_detail.nil?

        hesa_trainee_detail = Hesa::TraineeDetail.build(trainee:)

        attributes = {}
        attributes.merge!(extract_attributes_from_student_record)
        attributes.merge!(extract_attributes_from_metadatum_record)
        hesa_trainee_detail.assign_attributes(attributes)

        hesa_trainee_detail.save
      end

    private

      attr_reader :trainee

      def extract_attributes_from_metadatum_record
        return {} if trainee.hesa_metadatum.nil?

        required_attributes = Hesa::Metadatum.new.attributes.keys.intersection(Hesa::TraineeDetail.new.attributes.keys) - %w[id trainee_id created_at updated_at]

        trainee.hesa_metadatum.slice(required_attributes).compact!
      end

      def extract_attributes_from_student_record
        return {} if trainee.hesa_students.empty?

        required_attributes = Hesa::Student.new.attributes.keys.intersection(Hesa::TraineeDetail.new.attributes.keys) - %w[id trainee_id created_at updated_at]

        trainee.hesa_students.last.slice(required_attributes).compact!
      end
    end
  end
end
