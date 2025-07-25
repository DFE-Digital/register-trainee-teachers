# frozen_string_literal: true

module SchoolData
  class ImportService
    include ServicePattern

    def initialize(filtered_csv_path:, download_record:)
      @filtered_csv_path = filtered_csv_path
      @download_record = download_record
      @stats = { created: 0, updated: 0, lead_partners_updated: 0 }
    end

    def call
      import_schools
      realign_lead_partners
      update_final_stats
      cleanup_files

      @stats
    end

  private

    def import_schools
      Rails.logger.info("Reading filtered CSV: #{@filtered_csv_path} (#{File.size(@filtered_csv_path)} bytes)")

      School.transaction do
        CSV.foreach(@filtered_csv_path, headers: true) do |row|
          import_single_school(row)
        end
      end
    end

    def import_single_school(row)
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

    def realign_lead_partners
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

    def cleanup_files
      FileUtils.rm_f(@filtered_csv_path)
    end
  end
end
