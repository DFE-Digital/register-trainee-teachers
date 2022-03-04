# frozen_string_literal: true

class AddMissingProviders < ActiveRecord::Migration[6.1]
  def up
    [
      { ukprn: 10000961, name: "Brunel University London", dttp_id: "cc70f34a-2887-e711-80d8-005056ac45bb", code: "B84" },
      { ukprn: 10003645, name: "King's College London", dttp_id: "d470f34a-2887-e711-80d8-005056ac45bb", code: "K60" },
      { ukprn: 10003861, name: "Leeds Beckett University", dttp_id: "d870f34a-2887-e711-80d8-005056ac45bb", code: "L27" },
      { ukprn: 10003957, name: "Liverpool John Moores University", dttp_id: "de70f34a-2887-e711-80d8-005056ac45bb", code: "L51" },
      { ukprn: 10004113, name: "Loughborough University", dttp_id: "e470f34a-2887-e711-80d8-005056ac45bb", code: "L79" },
      { ukprn: 10006840, name: "The University Of Birmingham", dttp_id: "fe70f34a-2887-e711-80d8-005056ac45bb", code: "B32" },
      { ukprn: 10006841, name: "The University Of Bolton", dttp_id: "dfdb7129-7042-e811-80ff-3863bb3640b8", code: "8N5" },
      { ukprn: 10007154, name: "University of Nottingham", dttp_id: "2c71f34a-2887-e711-80d8-005056ac45bb", code: "N84" },
      { ukprn: 10007157, name: "The University Of Sheffield", dttp_id: "3671f34a-2887-e711-80d8-005056ac45bb", code: "S18" },
      { ukprn: 10007167, name: "University Of York", dttp_id: "4a71f34a-2887-e711-80d8-005056ac45bb", code: "Y50" },
      { ukprn: 10007713, name: "York St John University", dttp_id: "4c71f34a-2887-e711-80d8-005056ac45bb", code: "Y75" },
      { ukprn: 10007774, name: "University Of Oxford", dttp_id: "2e71f34a-2887-e711-80d8-005056ac45bb", code: "O33" },
      { ukprn: 10007776, name: "Roehampton University", dttp_id: "f270f34a-2887-e711-80d8-005056ac45bb", code: "1F9" },
      { ukprn: 10007786, name: "University Of Bristol", dttp_id: "0271f34a-2887-e711-80d8-005056ac45bb", code: "B78" },
      { ukprn: 10007788, name: "University of Cambridge", dttp_id: "0671f34a-2887-e711-80d8-005056ac45bb", code: "C05" },
      { ukprn: 10007789, name: "The University Of East Anglia", dttp_id: "1271f34a-2887-e711-80d8-005056ac45bb", code: "E14" },
      { ukprn: 10007792, name: "University Of Exeter", dttp_id: "1671f34a-2887-e711-80d8-005056ac45bb", code: "E84" },
      { ukprn: 10007796, name: "University of Leicester", dttp_id: "2471f34a-2887-e711-80d8-005056ac45bb", code: "2HX" },
      { ukprn: 10007798, name: "The University Of Manchester", dttp_id: "2671f34a-2887-e711-80d8-005056ac45bb", code: "M20" },
      { ukprn: 10007799, name: "University Of Newcastle Upon Tyne", dttp_id: "909e1d2d-3fa2-e811-812b-5065f38ba241", code: "N21" },
      { ukprn: 10007801, name: "University Of Plymouth", dttp_id: "3071f34a-2887-e711-80d8-005056ac45bb", code: "P60" },
      { ukprn: 10007823, name: "Edge Hill University", dttp_id: "d070f34a-2887-e711-80d8-005056ac45bb", code: "E42" },
    ].each do |attributes|
      Provider.find_or_create_by(attributes)
    end

    Provider.find_by(id: 80)&.update(ukprn: 10004180)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
