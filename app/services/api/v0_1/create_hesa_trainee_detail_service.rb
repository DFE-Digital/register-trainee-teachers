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

        required_attributes = %i[itt_aim itt_qualification_aim pg_apprenticeship_start_date]

        trainee.hesa_metadatum.slice(required_attributes)
      end

      def extract_attributes_from_student_record
        return {} if trainee.hesa_students.empty?

        required_attributes = %i[course_age_range itt_aim itt_qualification_aim fund_code pg_apprenticeship_start_date ni_number]

        trainee.hesa_students.last.slice(required_attributes)
      end
    end
  end
end
