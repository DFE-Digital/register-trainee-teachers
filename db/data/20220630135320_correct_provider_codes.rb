# frozen_string_literal: true

class CorrectProviderCodes < ActiveRecord::Migration[6.1]
  def up
    {
      "Roehampton University" => "R48",
      "University of Leicester" => "L34",
      "Devon Secondary Teacher Training Group (DSTTG)" => "D41",
      "Wessex Schools Training Partnership (EBITT)" => "W34",
      "Sussex Teacher Training Partnership" => "E37",
      "Inspiring Leaders - Teacher Training" => "2A5",
      "London South Bank University" => "L75",
      "Teesside University ITT" => "3S1",
      "Haybridge Alliance SCITT" => "2B3",
      "CREC Early Years Partnership" => "25P",
      "High Force Education SCITT" => "H38",
      "Oxfordshire Teacher Training" => "24T",
      "St. Joseph's College Stoke Secondary Partnership" => "1WJ",
      "Luminate Partnership for ITT" => "4L6",
    }.each do |name, code|
      Provider.find_by(name: name)&.update(code: code)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
