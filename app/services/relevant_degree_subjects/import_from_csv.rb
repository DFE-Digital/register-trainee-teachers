# frozen_string_literal: true

module RelevantDegreeSubjects
  class ImportFromCsv
    include ServicePattern

    attr_reader :upload, :academic_cycle, :unmatched_allocation_subjects, :invalid_hecos_codes

    def initialize(upload_id:, academic_cycle:)
      @upload = Upload.find(upload_id)
      @academic_cycle = academic_cycle
      @unmatched_allocation_subjects = []
      @invalid_hecos_codes = []
    end

    def call
      rows = CSV.parse(upload.file.download, headers: true, header_converters: :symbol)

      rows.each do |row|
        allocation_subject = AllocationSubject.find_by(name: row[:allocation_subject]&.strip)

        if allocation_subject.nil?
          unmatched_allocation_subjects << row[:allocation_subject]
          next
        end

        relevant_degree_subject = RelevantDegreeSubject.find_or_create_by(
          academic_cycle: academic_cycle,
          allocation_subject: allocation_subject,
          hecos_code: row[:hecos_code],
        )

        invalid_hecos_codes << row[:hecos_code] unless relevant_degree_subject.persisted?
      end

      self
    end
  end
end
