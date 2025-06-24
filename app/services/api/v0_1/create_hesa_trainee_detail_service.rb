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

        attributes = extract_attributes_from_student_record
        attributes.merge!(extract_attributes_from_metadatum_record(attributes))
        hesa_trainee_detail.assign_attributes(attributes)

        hesa_trainee_detail.save
      end

    private

      attr_reader :trainee

      def extract_attributes_from_metadatum_record(existing_attributes)
        return {} if trainee.hesa_metadatum.nil?

        attributes_for_extraction = %i[itt_aim itt_qualification_aim pg_apprenticeship_start_date]
        attributes_for_extraction = attributes_for_extraction.map! { |attribute| attribute if existing_attributes[attribute].nil? }.compact

        trainee.hesa_metadatum.slice(attributes_for_extraction)
      end

      def extract_attributes_from_student_record
        return {} if trainee.hesa_students.empty?

        attributes_for_extraction = %i[course_age_range itt_aim itt_qualification_aim fund_code pg_apprenticeship_start_date ni_number]

        attributes = trainee.hesa_students.latest.slice(attributes_for_extraction)
        attributes.merge!(funding_method: trainee.hesa_students.last.bursary_level)
      end
    end
  end
end
