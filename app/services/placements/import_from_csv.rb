# frozen_string_literal: true

module Placements
  class ImportFromCsv
    include ServicePattern

    attr_reader :upload, :unmatched_hesa_ids, :unmatched_urns

    def initialize(upload_id:)
      @upload = Upload.find(upload_id)
      @unmatched_hesa_ids = []
      @unmatched_urns = []
    end

    def call
      # Uploaded CSV file should contain hesa_id and urn headers only
      placement_data = CSV.parse(upload.file.download, headers: true, header_converters: :symbol)

      placement_data.each do |row|
        if (trainee = matching_trainee_in_previous_cycle(row[:hesa_id]))
          urn = row[:urn]
          school = School.find_by(urn:)

          if school.present?
            Placement.find_or_create_by(trainee:, school:)
          elsif valid_unknown_school_urn?(urn)
            # Update name separately to avoid unique constraint violation with index on trainee_id and urn
            Placement.find_or_create_by(trainee:, urn:).update(name: I18n.t("components.placement_detail.magic_urn.#{urn}"))
          else
            unmatched_urns << urn
          end
        else
          unmatched_hesa_ids << row[:hesa_id]
        end
      end

      self
    end

  private

    def matching_trainee_in_previous_cycle(hesa_id)
      AcademicCycle.previous.total_trainees.find_by(hesa_id:)
    end

    def valid_unknown_school_urn?(urn)
      # Check if the urn is one of the HESA codes for not applicable school URNs
      urn.in?(Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS)
    end
  end
end
