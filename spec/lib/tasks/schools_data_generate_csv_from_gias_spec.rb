# frozen_string_literal: true

require "rails_helper"
require "tempfile"

describe "schools_data:generate_csv_from_gias" do
  before do
    allow($stdout).to receive(:puts)
  end

  let(:external_csv_header) do
    '"URN","LA (code)","LA (name)","EstablishmentNumber","EstablishmentName","TypeOfEstablishment (name)","EstablishmentStatus (name)","ReasonEstablishmentOpened (name)","OpenDate","PhaseOfEducation (name)","StatutoryLowAge","StatutoryHighAge","Boarders (name)","OfficialSixthForm (name)","Gender (name)","ReligiousCharacter (name)","AdmissionsPolicy (name)","UKPRN","Street","Locality","Address3","Town","County (name)","Postcode","SchoolWebsite","TelephoneNum","FaxNum","HeadTitle (name)","HeadFirstName","HeadLastName","HeadPreferredJobTitle","GOR (name)","ParliamentaryConstituency (code)","ParliamentaryConstituency (name)"'
  end

  let(:duplicated_school) do
    '"100100",,,,"The Duplicated School EstablishmentName",,,,"The Duplicated School OpenDate",,,,,,,,,,,"The Duplicated School Locality","The Duplicated School Address3","The Duplicated School Town",,"The Duplicated School Postcode",,,,,,,,,,'
  end

  let(:school) do
    '"100000",,,,"The School EstablishmentName",,,,"The School OpenDate",,,,,,,,,,,"The School Locality","The School Address3","The School Town",,"The School Postcode",,,,,,,,,,'
  end

  let(:university) do
    '"100000",,,,"The University EstablishmentName",,,,"The University OpenDate",,,,,,,,,,,"The University Locality","The University Address3","The University Town",,"The University Postcode",,,,,,,,,,'
  end

  let(:gias_csv_1_body) {
    <<~CSV
      #{external_csv_header}
      #{school}
      #{duplicated_school}
    CSV
  }
  let(:gias_csv_2_body) {
    <<~CSV
      #{external_csv_header}
      #{duplicated_school}
      #{university}
    CSV
  }

  let(:gias_csv_1_file) do
    Tempfile.new(["edubaseallacademiesandfree", ".csv"]).tap do |f|
      f.write gias_csv_1_body
      f.flush
      f.close
    end
  end

  let(:gias_csv_2_file) do
    Tempfile.new(["edubaseallstatefunded", ".csv"]).tap do |f|
      f.write gias_csv_2_body
      f.flush
      f.close
    end
  end

  let(:output_path) do
    Tempfile.new(["fake", ".csv"]).path
  end

  subject do
    args = Rake::TaskArguments.new(
      %i[gias_csv_1_path gias_csv_2_path output_path],
      [gias_csv_1_file.path, gias_csv_2_file.path, output_path],
    )
    Rake::Task["schools_data:generate_csv_from_gias"].execute(args)
  end

  it "combines the relevant fields and outputs them to a csv" do
    subject

    row1, row2 = *CSV.read(output_path, headers: true).map(&:to_h)
    expect(row1).to eq(
      {
        "name" => "The School EstablishmentName",
        "open_date" => "The School OpenDate",
        "postcode" => "The School Postcode",
        "town" => "The School Town",
        "urn" => "100000",
      },
    )

    expect(row2).to eq(
      {
        "name" => "The Duplicated School EstablishmentName",
        "open_date" => "The Duplicated School OpenDate",
        "postcode" => "The Duplicated School Postcode",
        "town" => "The Duplicated School Town",
        "urn" => "100100",
      },
    )
  end
end
