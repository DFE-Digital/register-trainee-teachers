# frozen_string_literal: true

module Api
  module V01
    class CreateHesaTraineeDetailService
      include ServicePattern

      def initialize(trainee:)
        @trainee = trainee
      end

      def call
        return false unless trainee.hesa_trainee_detail.nil?

        hesa_trainee_detail = Hesa::TraineeDetail.build(trainee:)

        attributes = extract_attributes_from_student_record
        attributes.merge!(extract_attributes_from_metadatum_record(attributes))
        hesa_trainee_detail.assign_attributes(attributes)

        hesa_trainee_detail.save!
      end

    private

      attr_reader :trainee

      def extract_attributes_from_metadatum_record(existing_attributes)
        return {} if trainee.hesa_metadatum.nil?

        attributes = {}
        attributes = { fund_code: trainee.hesa_metadatum.fundability } if existing_attributes[:fund_code].nil?
        attributes_for_extraction = %i[itt_aim itt_qualification_aim pg_apprenticeship_start_date]
        attributes_for_extraction = attributes_for_extraction.map! { |attribute| attribute if existing_attributes[attribute].nil? }.compact

        attributes.merge!(trainee.hesa_metadatum.slice(attributes_for_extraction))
      end

      def extract_attributes_from_student_record
        return {} if trainee.hesa_students.empty?

        attributes_for_extraction = %i[course_age_range itt_aim itt_qualification_aim fund_code pg_apprenticeship_start_date ni_number]

        student_record = trainee.hesa_students.latest
        attributes = student_record.slice(attributes_for_extraction)
        attributes.merge!(
          funding_method: student_record.bursary_level,
          previous_last_name: student_record.previous_surname,
          course_study_mode: student_record.mode,
          course_year: student_record.year_of_course,
          hesa_disabilities: disabilities(student_record),
          additional_training_initiative: student_record.training_initiative,
        )
      end

      def disabilities(student_record)
        (1..9).to_h { |integer| ["disability#{integer}", student_record.send("disability#{integer}")] }.compact!
      end
    end
  end
end
