# frozen_string_literal: true

class AddMissingDttpImportProviders < ActiveRecord::Migration[6.1]
  def up
    [
      { ukprn: 10061209, name: "Consilium SCITT", dttp_id: "d470f34a-2887-e711-80d8-005056ac45bb", code: "1MS" },
      { ukprn: 10007799, name: "Newcastle University", dttp_id: "ea70f34a-2887-e711-80d8-005056ac45bb", code: "N21" },
      { ukprn: 10007843, name: "St Mary's University", dttp_id: "f670f34a-2887-e711-80d8-005056ac45bb", code: "S64" },
    ].each do |attributes|
      Provider.find_or_create_by(attributes)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
