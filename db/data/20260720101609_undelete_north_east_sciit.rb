# frozen_string_literal: true

class UndeleteNorthEastSciit < ActiveRecord::Migration[8.1]
  def up
    Provider.find_by!(name: "North East SCITT", code: "L06")
      .undiscard!
  end

  def down
    Provider.find_by!(name: "North East SCITT", code: "L06")
      .discard!
  end
end
