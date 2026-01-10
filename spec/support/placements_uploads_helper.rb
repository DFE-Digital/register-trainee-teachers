# frozen_string_literal: true

module PlacementsUploadHelper
  def create_placements_upload_csv!(trainees: Trainee.all, overwrite: [], write_to_disk: false, columns_to_delete: [])
    # use bulk change status export to generate a CSV using the same CSV args that are
    # used to read it in the upload form
    csv = CSV.parse(
      ::Exports::BulkPlacementExport.call(trainees).to_s,
      **::BulkUpdate::PlacementsForm::CSV_ARGS,
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
end
