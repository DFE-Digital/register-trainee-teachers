# frozen_string_literal: true

class FixUnmappedTraineeDegreeSubjects < ActiveRecord::Migration[7.0]
  UNKNOWN_NOT_APPLICABLE_SUBJECT_HESA_CODES = %w[999999 999998].freeze

  def up
    degrees = Degree.where(subject: nil)

    degrees.find_each do |degree|
      hesa_student = degree.trainee.hesa_student

      next unless hesa_student

      degree_subject_hesa_codes = hesa_student.degrees.map { |d| d["subject"] }

      degree_subject_hesa_codes.each do |subject_hesa_code|
        next unless UNKNOWN_NOT_APPLICABLE_SUBJECT_HESA_CODES.include?(subject_hesa_code)

        subject = DfEReference::DegreesQuery.find_subject(hecos_code: subject_hesa_code)
        degree.subject = subject&.name
        degree.subject_uuid = subject&.id
        degree.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
