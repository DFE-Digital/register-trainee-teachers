# frozen_string_literal: true

module SchoolData
  class ImportService
    include ServicePattern

    def initialize(csv_files:, download_record:)
      @csv_files = Array(csv_files)
      @download_record = download_record
      @stats = { created: 0, updated: 0, errors: [] }
      @temporary_files = []
    end

    def call
      @download_record.update!(status: :processing)

      validate_csv_files
      combined_csv_path = generate_combined_csv
      import_schools(combined_csv_path)
      realign_lead_partners
      update_final_stats
      cleanup_files
      @stats
    rescue StandardError => e
      handle_error(e)
      raise
    end

  private

    attr_reader :csv_files, :download_record, :stats, :temporary_files

    def validate_csv_files
      unless csv_files.size == 2
        raise("Expected 2 CSV files, got #{csv_files.size}")
      end

      csv_files.each do |file_path|
        unless File.exist?(file_path)
          raise("CSV file not found: #{file_path}")
        end

        unless File.readable?(file_path)
          raise("CSV file not readable: #{file_path}")
        end
      end
    end

    def generate_combined_csv
      items = csv_files.flat_map do |csv_path|
        extract_school_data_from_csv(csv_path)
      end

      # Remove duplicates by URN and sort
      items = items.uniq { |item| item[:urn] }
      items = items.sort { |a, b| a[:urn] <=> b[:urn] }

      # Write to temporary combined CSV
      combined_csv_path = Rails.root.join("tmp", "schools_gias_combined_#{Time.current.to_i}.csv")
      temporary_files << combined_csv_path

      CSV.open(combined_csv_path, "w+") do |csv|
        csv << items.first.keys if items.any?
        items.each do |hash|
          csv << hash.values
        end
      end

      combined_csv_path
    end

    def extract_school_data_from_csv(csv_path)
      # Use the same encoding handling as the rake task
      schools = CSV.read(csv_path, headers: true, encoding: "windows-1251:utf-8")

      schools.map do |school|
        urn = school["URN"]&.strip
        next if urn.blank?

        # Handle missing town data with fallback logic from rake task
        town = school["Town"].presence || [school["Address3"], school["Locality"]].detect(&:present?).tap do |backup|
          Rails.logger.warn("Town missing for school: '#{school['EstablishmentName']}', estimating as #{backup}")
        end

        {
          urn: urn,
          name: school["EstablishmentName"]&.strip,
          open_date: school["OpenDate"].presence,
          town: town&.strip,
          postcode: school["Postcode"]&.strip,
        }
      end.compact
    end

    def import_schools(csv_path)
      School.transaction do
        CSV.foreach(csv_path, headers: true, encoding: "utf-8") do |row|
          import_single_school(row)
        end
      end

      Rails.logger.info("Import completed: #{stats[:created]} created, #{stats[:updated]} updated, #{stats[:errors].size} errors")
    end

    def import_single_school(row)
      urn = row["urn"]&.strip
      return if urn.blank?

      school = School.find_or_initialize_by(urn:)
      attributes = extract_school_attributes(row)

      if school.new_record?
        school.assign_attributes(attributes)
        school.save!
        @stats[:created] += 1
      else
        school.update!(attributes)
        @stats[:updated] += 1
      end
    rescue StandardError => e
      error_info = { urn: urn, error: e.message }
      @stats[:errors] << error_info
      Rails.logger.error("Failed to import school URN #{urn}: #{e.message}")
    end

    def extract_school_attributes(row)
      {
        name: row["name"]&.strip,
        open_date: parse_date(row["open_date"]),
        town: row["town"]&.strip,
        postcode: row["postcode"]&.strip,
      }
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
        lead_partner.name
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
      download_record.update!(
        status: :completed,
        completed_at: Time.zone.current,
        file_count: csv_files.size,
        schools_created: stats[:created],
        schools_updated: stats[:updated],
      )
    end

    def cleanup_files
      temporary_files.each do |file_path|
        FileUtils.rm_f(file_path)
      end
    end

    def handle_error(error)
      Rails.logger.error("School data import failed: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n"))

      download_record.update!(
        status: :failed,
        completed_at: Time.current,
        error_message: error.message,
      )

      cleanup_files
    end
  end
end
