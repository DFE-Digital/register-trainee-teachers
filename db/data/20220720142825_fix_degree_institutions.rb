# frozen_string_literal: true

class FixDegreeInstitutions < ActiveRecord::Migration[6.1]
  def up
    mapped_values = [
      ["Other UK", "Other", nil],
      ["Other UK (Wales)", "Other", nil],
      ["The Queen's University of Belfast", "Queen’s University Belfast", "a7db7129-7042-e811-80ff-3863bb3640b8"],
      ["Not applicable", nil, nil],
      ["West London Institute of HE", "Other", nil],
      ["The City University", "City, University of London", "293e182c-1425-ec11-b6e6-000d3adf095a"],
      ["St Mary's University, Twickenham", "St Mary’s University, Twickenham", "f670f34a-2887-e711-80d8-005056ac45bb"],
      ["Ravensbourne", "Ravensbourne University London", "4ff3791d-7042-e811-80ff-3863bb3640b8"],
      ["Wimbledon School of Art", "University of Surrey", "58228041-7042-e811-80ff-3863bb3640b8"],
      ["Queen's University Belfast", "Queen’s University Belfast", "a7db7129-7042-e811-80ff-3863bb3640b8"],
      ["Other UK (Scotland)", "Other", nil],
      ["University of Glamorgan", "University of South Wales", "8723a753-7042-e811-80ff-3863bb3640b8"],
      ["Institute Of Art - London Limited", "Sotheby’s Institute of Art", "5b3e182c-1425-ec11-b6e6-000d3adf095a"],
      ["St George's Hospital Medical School", "St George’s, University of London", "94407223-7042-e811-80ff-3863bb3640b8"],
      ["Other EU countries", "Degree institution shouldn't be needed", nil],
      ["St Mary's University College", "St Mary’s University College, Belfast", "9b407223-7042-e811-80ff-3863bb3640b8"],
      ["Norwich City College of Further and Higher Education", "The City College", "e93e182c-1425-ec11-b6e6-000d3adf095a"],
      ["Non EU countries", "Degree institution shouldn't be needed", nil],
      ["Dartington College of Arts", "Falmouth University", "6f955cae-3ea2-e811-812b-5065f38ba241"],
      ["Newcastle College", "NCG (Newcastle College Group)", "20e5a08c-ee97-e711-80d8-005056ac45bb"],
      ["The University of St. Andrews", "University of St Andrews", "34228041-7042-e811-80ff-3863bb3640b8"],
      ["SOAS University of London", "SOAS, University of London", "bddb7129-7042-e811-80ff-3863bb3640b8"],
      ["Winchester School of Art", "University of Southampton", "4f5b7f3b-7042-e811-80ff-3863bb3640b8"],
      ["Institute of Education", "University of London", "0d791c39-3fa2-e811-812b-5065f38ba241"],
      ["St George's, University of London", "St George’s, University of London", "94407223-7042-e811-80ff-3863bb3640b8"],
      ["Regent's University London Limited", "Regent’s University London", "c33e182c-1425-ec11-b6e6-000d3adf095a"],
      ["Northern School of Contemporary Dance", "Other", "2f3e182c-1425-ec11-b6e6-000d3adf095a"],
      ["SAE Education Limited", "SAE Education", "d33e182c-1425-ec11-b6e6-000d3adf095a"],
      ["Not available in EBRDMS", "Not applicable", nil],
      ["West Suffolk College", "University of East Anglia", "1271f34a-2887-e711-80d8-005056ac45bb"],
      ["Mattersey Hall", "Bible College Missio Dei", "933e182c-1425-ec11-b6e6-000d3adf095a"],
    ]

    mapped_values.each do |values|
      Degree.where(institution: values[0]).update_all(institution: values[1], institution_uuid: values[2])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
