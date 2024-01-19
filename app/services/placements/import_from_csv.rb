# frozen_string_literal: true

module Placements
  class ImportFromCsv
    include ServicePattern

    def initialize(upload_id:)
      @upload = Upload.find(upload_id)
    end

    # Uploaded CSV file should contain hesa_id and urn headers only
    def call
      table = CSV.parse(upload.file.download, headers: true)
      table.each do |row|
        next unless (school = School.find_by(urn: row["urn"]))
        next unless (trainee = Trainee.find_by(hesa_id: row["hesa_id"]))

        Placement.find_or_create_by(trainee:, school:)
      end
    end

  private

    attr_reader :upload
  end
end
