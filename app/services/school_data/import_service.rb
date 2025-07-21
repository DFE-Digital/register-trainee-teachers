# frozen_string_literal: true

module SchoolData
  class ImportService
    include ServicePattern

    def initialize(filtered_csv_path:, download_record:)
      @filtered_csv_path = filtered_csv_path
      @download_record = download_record
      @stats = { created: 0, updated: 0, errors: [], lead_partners_updated: 0 }
    end

    def call
      @download_record.update!(status: :processing)

      validate_csv_file
      import_schools
      realign_lead_partners
      update_final_stats
      cleanup_files

      @stats
    rescue StandardError => e
      handle_error(e)
      raise
    end

  private

    def validate_csv_file
      unless File.exist?(@filtered_csv_path)
        raise("Filtered CSV file not found: #{@filtered_csv_path}")
      end

      unless File.readable?(@filtered_csv_path)
        raise("Filtered CSV file not readable: #{@filtered_csv_path}")
      end
    end

    def import_schools
      School.transaction do
        CSV.foreach(@filtered_csv_path, headers: true, encoding: "utf-8") do |row|
          import_single_school(row)
        end
      end

      Rails.logger.info("Import completed: #{@stats[:created]} created, #{@stats[:updated]} updated, #{@stats[:errors].size} errors")
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
    rescue StandardError => e
      error_info = { urn: urn, error: e.message }
      @stats[:errors] << error_info
      Rails.logger.error("Failed to import school URN #{urn}: #{e.message}")
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

      if town.blank?
        Rails.logger.warn("Town missing for school: '#{row['EstablishmentName']}' URN: #{row['URN']}")
      end

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
      success_count = 0
      lead_partners = LeadPartner.school.joins(:school).includes(:school)
                                 .where("lead_partners.name != schools.name")

      lead_partners.find_each do |lead_partner|
        new_name = lead_partner.school.name
        lead_partner.name = new_name

        if lead_partner.save
          success_count += 1
        else
          Rails.logger.error("Failed to update lead partner #{lead_partner.id}: #{lead_partner.errors.full_messages.join(', ')}")
        end
      end

      @stats[:lead_partners_updated] = success_count
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
      FileUtils.rm_f(@filtered_csv_path) if File.exist?(@filtered_csv_path)
    end

    def handle_error(error)
      Rails.logger.error("School data import failed: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n"))

      @download_record.update!(
        status: :failed,
        completed_at: Time.current,
        error_message: error.message,
      )

      cleanup_files
    end
  end
end
