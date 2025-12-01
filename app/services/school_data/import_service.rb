# frozen_string_literal: true

module SchoolData
  class ImportService
    include ServicePattern

    EXCLUDED_ESTABLISHMENT_TYPES = [29].freeze

    def initialize(csv_content:, download_record:)
      @csv_rows = CSV.parse(csv_content, headers: true)
      @download_record = download_record
      @stats = { created: 0, updated: 0, lead_partners_updated: 0, total_rows: 0, filtered_rows: 0 }
    end

    def call
      import_schools
      delete_schools
      realign_lead_partner_names
      update_final_stats
      log_final_stats

      @stats
    end

  private

    def import_schools
      School.transaction do
        @csv_rows.each do |row|
          @stats[:total_rows] += 1
          import_single_school(row)
        end
      end
    end

    def import_single_school(row)
      establishment_type = row["TypeOfEstablishment (code)"]&.to_i
      if EXCLUDED_ESTABLISHMENT_TYPES.include?(establishment_type)
        @stats[:filtered_rows] += 1
        return
      end

      urn = row["URN"]&.strip
      return if urn.blank?

      school = School.find_or_initialize_by(urn:)
      attributes = extract_school_attributes(row)

      school.assign_attributes(attributes)
      if school.new_record?
        school.save!
        @stats[:created] += 1
      elsif school.changed?
        school.save!
        @stats[:updated] += 1
      end
    end

    def extract_school_attributes(row)
      {
        name: row["EstablishmentName"]&.strip,
        open_date: parse_date(row["OpenDate"]),
        close_date: parse_date(row["CloseDate"]),
        town: extract_town(row),
        postcode: row["Postcode"]&.strip,
      }
    end

    def extract_town(row)
      # Full GIAS CSV has multiple address fields - use fallback logic
      town = row["Town"].presence ||
             row["Address3"].presence ||
             row["Locality"].presence

      town&.strip
    end

    def parse_date(date_string)
      return nil if date_string.blank?

      Date.parse(date_string)
    rescue Date::Error
      Rails.logger.warn("Failed to parse date: #{date_string}")
      nil
    end

    def delete_schools
      gias_schools = @csv_rows.map { |row| row["URN"]&.strip }.compact
      # Only delete schools that are not associated with any trainees or funding records or placements
      register_schools_to_delete = School.where.not(urn: gias_schools)
                                         .where.missing(:employing_school_trainees,
                                                        :lead_partner_trainees,
                                                        :funding_payment_schedules,
                                                        :funding_trainee_summaries,
                                                        :placements)

      register_schools_to_delete.find_each(&:destroy!)
    end

    def realign_lead_partner_names
      lead_partners = LeadPartner.school.joins(:school).includes(:school)
                                 .where("lead_partners.name != schools.name")

      lead_partners.find_each do |lead_partner|
        lead_partner.update!(name: lead_partner.school.name)
        @stats[:lead_partners_updated] += 1
      end
    end

    def update_final_stats
      @download_record.update!(
        status: :completed,
        completed_at: Time.current,
        schools_created: @stats[:created],
        schools_updated: @stats[:updated],
        lead_partners_updated: @stats[:lead_partners_updated],
      )
    end

    def log_final_stats
      kept_rows = @stats[:total_rows] - @stats[:filtered_rows]
      Rails.logger.info("Processed #{@stats[:total_rows]}. Kept #{kept_rows}. Filtered out: #{@stats[:filtered_rows]}")
    end
  end
end
