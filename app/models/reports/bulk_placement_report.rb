# frozen_string_literal: true

module Reports
  class BulkPlacementReport < TemplateClassCsv
    PLACEMENT_HEADERS = (1..BulkUpdate::Placements::Config::DEFAULT_NUM_PLACEMENTS).map { |i| "Placement #{i} URN" }.freeze
    OPTIONAL_HEADERS = ((BulkUpdate::Placements::Config::DEFAULT_NUM_PLACEMENTS + 1)..BulkUpdate::Placements::Config::MAX_PLACEMENTS).map { |i| "Placement #{i} URN" }

    HEADERS = [
      "TRN",
      "Trainee ITT start date",
      *PLACEMENT_HEADERS,
    ].freeze

    EXPORT_HEADERS = [*HEADERS, *OPTIONAL_HEADERS].freeze

    PLACEMENT_GUIDANCE = "URNs must be 6 digits long.\n\n\nIf you do not know the placement school's URN, leave the cell empty."

    GUIDANCE = [
      "Do not change this column",
      "Do not change this column",
      "The URN of the trainee's first placement school.\n\n\n#{PLACEMENT_GUIDANCE}",
      "The URN of the trainee's second placement school.\n\n\n#{PLACEMENT_GUIDANCE}",
      "The URN of the trainee's third placement school.\n\n\n#{PLACEMENT_GUIDANCE}",
      "The URN of the trainee's fourth placement school.\n\n\n#{PLACEMENT_GUIDANCE}",
      "The URN of the trainee's fifth placement school.\n\n\n#{PLACEMENT_GUIDANCE}",
    ].freeze

    ADDED_MANUALLY = "ADDED MANUALLY"
    PLACEMENT_POSITIONS = %i[first second third fourth fifth].freeze

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
    end

    alias trainees scope

  private

    def add_headers
      csv << EXPORT_HEADERS
      csv << GUIDANCE
    end

    def add_report_rows
      trainees.each do |trainee|
        add_trainee_to_csv(trainee)
      end
    end

    def add_trainee_to_csv(trainee)
      csv << [
        trainee.trn,
        trainee.itt_start_date.to_fs(:govuk_slash),
        *placement_urns(trainee),
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
    end

    def placement_urns(trainee)
      PLACEMENT_POSITIONS.map { |position| placement(trainee, position) }
    end

    def placement(trainee, position)
      placement = trainee.placements.send(position)
      return unless placement

      placement&.school&.urn.presence || ADDED_MANUALLY
    end
  end
end
