# frozen_string_literal: true

module Reports
  class BulkPlacementReport < TemplateClassCsv
    PLACEMENT_HEADERS = Array.new(BulkUpdate::Placements::Config::MAX_PLACEMENTS) { |i| "Placement #{i + 1} URN" }.freeze

    HEADERS = [
      "TRN",
      "Trainee ITT start date",
      *PLACEMENT_HEADERS,
    ].freeze

    GUIDANCE = [
      "Do not change this column",
      "When the trainee started their ITT.\n\n\nMust be written DD/MM/YYYY.\n\n\nFor example, if the trainee started their ITT on 20 September 2021, write '20/09/2021'.\n\n\nThe date must be in the past.\n\n\nIf you do not know the trainee’s ITT start date, leave the cell empty.",
      "The URN of the trainee’s first placement school.\n\n\nURNs must be 6 digits long.\n\n\nIf you do not know the placement school’s URN, leave the cell empty.",
      "The URN of the trainee’s second placement school.\n\n\nURNs must be 6 digits long.\n\n\nIf you do not know the placement school’s URN, leave the cell empty.",
    ].freeze

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

      placement&.school&.urn.presence || "ADDED MANUALLY"
    end
  end
end
