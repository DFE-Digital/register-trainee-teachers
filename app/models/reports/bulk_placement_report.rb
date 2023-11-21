# frozen_string_literal: true

module Reports
  class BulkPlacementReport < TemplateClassCsv
    HEADERS = [
      "TRN",
      "Trainee ITT start date",
      "Placement 1 URN",
      "Placement 2 URN",
    ].freeze

    GUIDANCE = [
      "Do not change this column",
      "When the trainee started their ITT.\nMust be written DD/MM/YYYY.\nFor example, if the trainee started their ITT on 20 September 2021, write '20/09/2021'.\nThe date must be in the past.\nIf you do not know the trainee’s ITT start date, leave the cell empty.",
      "The URN of the trainee’s first placement school.\nURNs must be 6 digits long.\nIf you do not know the placement school’s URN, leave the cell empty.",
      "The URN of the trainee’s second placement school.\nURNs must be 6 digits long.\nIf you do not know the placement school’s URN, leave the cell empty.",
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
      return csv << ["No trainee data to export"] if trainees.blank?

      trainees.strict_loading.includes(:placements).each do |trainee| # rubocop:disable Rails/FindEach
        add_trainee_to_csv(trainee)
      end
    end

    def add_trainee_to_csv(trainee)
      csv << csv_row(trainee)
    end

    def csv_row(trainee)
      row = [
        trainee.trn,
        trainee.itt_start_date,
        placement(trainee, :first),
        placement(trainee, :second),
      ].map { |value| CsvValueSanitiser.new(value).sanitise }

      row
    end

    def placement(trainee, position)
      placement = trainee.placements.send(position)

      return unless placement

      placement.urn.presence || "ADDED MANUALLY"
    end
  end
end
