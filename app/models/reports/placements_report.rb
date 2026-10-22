# frozen_string_literal: true

module Reports
  class PlacementsReport < TemplateClassCsv
    MAX_PLACEMENTS = BulkUpdate::Placements::Config::MAX_PLACEMENTS

    HEADERS = [
      "TRN",
      "Trainee ITT start date",
      "Education phase",
      *MAX_PLACEMENTS.times.flat_map { |i|
        ["Placement #{i + 1} URN", "Placement #{i + 1} address"]
      },
    ].freeze

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
      @current_academic_cycle = AcademicCycle.current
    end

    alias trainees scope

  private

    attr_reader :current_academic_cycle

    def add_headers
      csv << HEADERS
    end

    def add_report_rows
      trainees.each do |trainee|
        add_trainee_to_csv(trainee)
      end
    end

    def add_trainee_to_csv(trainee)
      csv << [
        trainee.trn,
        trainee.itt_start_date&.to_fs(:govuk_slash),
        education_phase(trainee),
        *placement_columns(trainee),
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
    end

    def education_phase(trainee)
      return EARLY_YEARS_ROUTE_NAME_PREFIX.humanize if trainee.early_years_route?

      trainee.course_education_phase&.upcase_first || trainee.course&.level&.capitalize
    end

    def placement_columns(trainee)
      placements = current_academic_year_placements(trainee)

      MAX_PLACEMENTS.times.flat_map do |index|
        placement = placements[index]
        [placement_urn(placement), placement_address(placement)]
      end
    end

    def current_academic_year_placements(trainee)
      trainee.placements
        .select { |placement| created_in_current_academic_cycle?(placement) }
        .first(MAX_PLACEMENTS)
    end

    def created_in_current_academic_cycle?(placement)
      placement.created_at.between?(
        current_academic_cycle.start_date.beginning_of_day,
        current_academic_cycle.end_date.end_of_day,
      )
    end

    def placement_urn(placement)
      placement&.urn
    end

    # e.g. "Bluemeadow Secondary College, URN 594773, Spencershire, Y7D 4NA"
    def placement_address(placement)
      return if placement.blank?
      return if School::NOT_APPLICABLE_SCHOOL_URNS.include?(placement.urn)

      [
        placement.name,
        urn_part(placement),
        *location_parts(placement),
      ].compact_blank.join(", ").presence
    end

    def urn_part(placement)
      "URN #{placement.urn}" if placement.urn.present?
    end

    # School: [town, postcode]. Manual: [address, postcode].
    def location_parts(placement)
      if placement.school.present?
        [placement.school.town, placement.school.postcode]
      else
        [placement.address, placement.postcode]
      end
    end
  end
end
