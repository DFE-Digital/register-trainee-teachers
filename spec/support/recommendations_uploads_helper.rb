# frozen_string_literal: true

module RecommendationsUploadHelper
  def create_recommendations_upload_csv!(trainees: Trainee.all, overwrite: [], write_to_disk: false)
    csv = CSV.parse(
      ::Exports::BulkRecommendExport.call(trainees).to_s,
      **::BulkUpdate::RecommendationsUploadForm::CSV_ARGS,
    )

    overwrite.each_with_index do |row, i|
      row.each do |key, value|
        # plus one because the first row is "do not edit"
        csv[i + 1][key.to_s.downcase] = value
      end
    end

    return csv unless write_to_disk

    tempfile = Tempfile.new("csv")
    tempfile.write(csv.to_s)
    tempfile.rewind
    tempfile.path
  end
end
