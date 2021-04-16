# frozen_string_literal: true

class ChangeNonUkDegreeNonNaricToNonEnic < ActiveRecord::Migration[6.1]
  NON_ENIC = "non_enic"
  NON_NARIC = "non_naric"

  def up
    execute <<~SQL.squish
      UPDATE degrees SET non_uk_degree = '#{NON_ENIC}' WHERE degrees.non_uk_degree = '#{NON_NARIC}'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE degrees SET non_uk_degree = '#{NON_NARIC}' WHERE degrees.non_uk_degree = '#{NON_ENIC}'
    SQL
  end
end
