# frozen_string_literal: true

require "rails_helper"
require "tempfile"

describe "schools_data:import" do
  before do
    allow($stdout).to receive(:puts)
  end

  let(:establishment_csv_body) { <<~CSV }
    "URN","LA (code)","LA (name)","EstablishmentNumber","EstablishmentName","TypeOfEstablishment (code)","TypeOfEstablishment (name)","EstablishmentTypeGroup (code)","EstablishmentTypeGroup (name)","EstablishmentStatus (code)","EstablishmentStatus (name)","ReasonEstablishmentOpened (code)","ReasonEstablishmentOpened (name)","OpenDate","ReasonEstablishmentClosed (code)","ReasonEstablishmentClosed (name)","CloseDate","PhaseOfEducation (code)","PhaseOfEducation (name)","StatutoryLowAge","StatutoryHighAge","Boarders (code)","Boarders (name)","NurseryProvision (name)","OfficialSixthForm (code)","OfficialSixthForm (name)","Gender (code)","Gender (name)","ReligiousCharacter (code)","ReligiousCharacter (name)","ReligiousEthos (name)","Diocese (code)","Diocese (name)","AdmissionsPolicy (code)","AdmissionsPolicy (name)","SchoolCapacity","SpecialClasses (code)","SpecialClasses (name)","CensusDate","NumberOfPupils","NumberOfBoys","NumberOfGirls","PercentageFSM","TrustSchoolFlag (code)","TrustSchoolFlag (name)","Trusts (code)","Trusts (name)","SchoolSponsorFlag (name)","SchoolSponsors (name)","FederationFlag (name)","Federations (code)","Federations (name)","UKPRN","FEHEIdentifier","FurtherEducationType (name)","OfstedLastInsp","OfstedSpecialMeasures (code)","OfstedSpecialMeasures (name)","LastChangedDate","Street","Locality","Address3","Town","County (name)","Postcode","SchoolWebsite","TelephoneNum","HeadTitle (name)","HeadFirstName","HeadLastName","HeadPreferredJobTitle","BSOInspectorateName (name)","InspectorateReport","DateOfLastInspectionVisit","NextInspectionVisit","TeenMoth (name)","TeenMothPlaces","CCF (name)","SENPRU (name)","EBD (name)","PlacesPRU","FTProv (name)","EdByOther (name)","Section41Approved (name)","SEN1 (name)","SEN2 (name)","SEN3 (name)","SEN4 (name)","SEN5 (name)","SEN6 (name)","SEN7 (name)","SEN8 (name)","SEN9 (name)","SEN10 (name)","SEN11 (name)","SEN12 (name)","SEN13 (name)","TypeOfResourcedProvision (name)","ResourcedProvisionOnRoll","ResourcedProvisionCapacity","SenUnitOnRoll","SenUnitCapacity","GOR (code)","GOR (name)","DistrictAdministrative (code)","DistrictAdministrative (name)","AdministrativeWard (code)","AdministrativeWard (name)","ParliamentaryConstituency (code)","ParliamentaryConstituency (name)","UrbanRural (code)","UrbanRural (name)","GSSLACode (name)","Easting","Northing","CensusAreaStatisticWard (name)","MSOA (name)","LSOA (name)","InspectorateName (name)","SENStat","SENNoStat","BoardingEstablishment (name)","PropsName","PreviousLA (code)","PreviousLA (name)","PreviousEstablishmentNumber","OfstedRating (name)","RSCRegion (name)","Country (name)","UPRN","SiteName","QABName (code)","QABName (name)","EstablishmentAccredited (code)","EstablishmentAccredited (name)","QABReport","CHNumber","MSOA (code)","LSOA (code)"
    100000,"201","City of London","3614","The Aldgate School","02","Voluntary aided school","4","Local authority maintained schools","1","Open","00","Not applicable","","00","Not applicable","","2","Primary",3,11,"1","No boarders","Has Nursery Classes","2","Does not have a sixth form","3","Mixed","02","Church of England","Does not apply","CE23","Diocese of London","0","Not applicable",274,"2","No Special Classes","16-01-2020","276","136","140","10.2","0","Not applicable","","","Not applicable","","Not under a federation","","",10079319,"","Not applicable","19-04-2013","0","Not applicable","04-02-2021","St James's Passage","Duke's Place","London","","","EC3A 5DE","www.sirjohncassprimary.org","02072831147","Miss","Alexandra","Allan","Headteacher","Not applicable","","","","Not applicable","","Not applicable","Not applicable","Not applicable","","","Not applicable","Not applicable","","","","","","","","","","","","","","","","","","","H","London","E09000001","City of London","E05009308","Portsoken","E14000639","Cities of London and Westminster","A1","(England/Wales) Urban major conurbation","E09000001",533498,181201,"","City of London 001","City of London 001F","","","","","","999","","","Outstanding","North-West London and South-Central England","","200000071925","","0","Not applicable","0","Not applicable","","","E02000001","E01032739"
    100001,"201","City of London","6005","City of London School for Girls","11","Other independent school","3","Independent schools","1","Open","00","Not applicable","01-01-1920","00","Not applicable","","0","Not applicable",7,18,"1","No boarders","No Nursery Classes","1","Has a sixth form","2","Girls","06","None","Inter- / non- denominational","0000","Not applicable","0","Not applicable",780,"2","No Special Classes","16-01-2020","744","0","744","0.0","0","Not applicable","","","Not applicable","","Not applicable","","",10013279,"","Not applicable","","0","Not applicable","12-04-2021","St Giles' Terrace","Barbican","","London","","EC2Y 8BB","http://www.clsg.org.uk","02078475500","Mrs","Jenny","Brown","Headteacher","Not applicable","","","","Not applicable","","Not applicable","Not applicable","Not applicable","","","Not applicable","Not approved","","","","","","","","","","","","","","","","","","","H","London","E09000001","City of London","E05009302","Cripplegate","E14000639","Cities of London and Westminster","A1","(England/Wales) Urban major conurbation","E09000001",532301,181746,"","City of London 001","City of London 001B","ISI",0,63,"Does not have boarders","Corporation of London","999","","","","North-West London and South-Central England","","200000074660","","0","Not applicable","0","Not applicable","","","E02000001","E01000002"
  CSV
  let(:establishment_csv) do
    Tempfile.new(["fake", ".csv"]).tap do |f|
      f.write establishment_csv_body
      f.flush
      f.close
    end
  end
  let(:establishment_csv_path) { establishment_csv.path }

  let(:lead_schools_csv_body) { <<~CSV }
    Academic Year,Date Added,Lead School (Name),Lead School (URN),Partner School (Name),Partner School (URN),,,,
    2020/21,-,4Derbyshire Teaching School Alliance,100000,Barlborough Primary School,112505,,Lead School (Name),Lead School (URN),COUNTUNIQUE of Partner School (URN)
  CSV
  let(:lead_schools_csv) do
    Tempfile.new(["fake", ".csv"]).tap do |f|
      f.write lead_schools_csv_body
      f.flush
      f.close
    end
  end
  let(:lead_schools_csv_path) { lead_schools_csv.path }

  let(:output_path) do
    Tempfile.new(["fake", ".csv"]).path
  end

  subject do
    args = Rake::TaskArguments.new(
      %i[establishment_csv_path lead_schools_csv_path output_path],
      [establishment_csv_path, lead_schools_csv_path, output_path],
    )
    Rake::Task["schools_data:build_csv"].execute(args)
  end

  it "combines the relevant fields and outputs them to a csv, tagging as lead school correctly" do
    subject

    row1, row2 = *CSV.read(output_path, headers: true).map(&:to_h)
    expect(row1).to eq(
      {
        "urn" => "100000",
        "name" => "The Aldgate School",
        "town" => "London",
        "postcode" => "EC3A 5DE",
        "lead_school" => "true",
        "open_date" => "",
        "close_date" => "",
      },
    )

    expect(row2).to eq(
      {
        "urn" => "100001",
        "name" => "City of London School for Girls",
        "town" => "London",
        "postcode" => "EC2Y 8BB",
        "lead_school" => "false",
        "open_date" => "01-01-1920",
        "close_date" => "",
      },
    )
  end
end
