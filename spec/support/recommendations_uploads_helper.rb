# frozen_string_literal: true

module RecommendationsUploadHelper
  def create_recommendations_upload_csv!(trainees: Trainee.all, overwrite: [], write_to_disk: false, columns_to_delete: [])
    # use bulk change status export to generate a CSV using the same CSV args that are
    # used to read it in the upload form
    csv = CSV.parse(
      ::Exports::BulkRecommendExport.call(trainees).to_s,
      **::BulkUpdate::RecommendationsUploadForm::CSV_ARGS,
    )

    # overwrite cell values
    overwrite.each_with_index do |row, i|
      row.each do |key, value|
        # plus one because the first row is "do not edit"
        csv[i + 1][key.to_s.downcase] = value
      end
    end

    # delete any unwanted columns
    columns_to_delete.each { |column| csv.delete(column) }

    # return a CSV object
    return csv unless write_to_disk

    # or return the path to a temp file on disk
    tempfile = Tempfile.new("csv")
    tempfile.write(csv.to_s)
    tempfile.rewind
    tempfile.path
  end

  def create_simplified_recommendations_upload_csv!(trainees:, write_to_disk:, recommended_for_award_date:)
    # create a CSV with only the columns that are required for the upload form
    csv_string = CSV.generate do |rows|
      rows << Reports::BulkRecommendEmptyReport::DEFAULT_HEADERS
      trainees.each do |trainee|
        rows << [
          trainee.trn,
          trainee.provider_trainee_id,
          recommended_for_award_date&.strftime("%d/%m/%Y"),
        ]
      end
    end

    # return a CSV object
    return csv_string unless write_to_disk

    # or return the path to a temp file on disk
    tempfile = Tempfile.new("csv")
    tempfile.write(csv_string)
    tempfile.rewind
    tempfile.path
  end

  def create_invalid_recommendations_upload_csv
    tempfile = Tempfile.new("csv")

    File.open(tempfile.path, "w:UTF-16LE") do |file|
      file.puts "invalid content"
    end

    tempfile.path
  end
end
