# frozen_string_literal: true

require "csv"

class AddEthnicityToBestPracticeNetwork < ActiveRecord::Migration[7.1]
  def up
    # removed and moved to app/services/add_ethnicity_from_csv.rb
  end

  def down; end
end
