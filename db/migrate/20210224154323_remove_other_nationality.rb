# frozen_string_literal: true

class RemoveOtherNationality < ActiveRecord::Migration[6.1]
  def up
    Nationality.find_by(name: Dttp::CodeSets::Nationalities::OTHER)&.destroy
  end

  def down
    Nationality.create!(name: Dttp::CodeSets::Nationalities::OTHER)
  end
end
