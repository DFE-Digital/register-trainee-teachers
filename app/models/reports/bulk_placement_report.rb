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

    GUIDANCE = [
      "Do not change this column",
      "Do not change this column",
      "The URN of the trainee’s first placement school.\n\n\nURNs must be 6 digits long.\n\n\nIf you do not know the placement school’s URN, leave the cell empty.",
      "The URN of the trainee’s second placement school.\n\n\nURNs must be 6 digits long.\n\n\nIf you do not know the placement school’s URN, leave the cell empty.",
    ].freeze

    ADDED_MANUALLY = "ADDED MANUALLY"

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
    end

    alias trainees scope

  private

    def add_headers
      csv << HEADERS
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
        placement(trainee, :first),
        placement(trainee, :second),
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
    end

    def placement(trainee, position)
      placement = trainee.placements.send(position)
      return unless placement

      placement&.school&.urn.presence || ADDED_MANUALLY
    end
  end
end
