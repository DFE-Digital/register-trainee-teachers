# frozen_string_literal: true

class FixIncorrectlyAwardedTrainees < ActiveRecord::Migration[6.1]
  def up
    %w[1869349
       2167324
       2050619
       1783569
       2150887
       1868823
       1783484
       2154104
       0953910
       2171220
       2050804
       2039650
       1989044
       1756250
       1989045
       2184778
       2184763
       0000359
       2152044
       1984572
       1783202
       1851456
       1783191
       2085157
       1870023
       2186312
       1783383
       1768281
       2168718
       2172014
       3961536].each do |trn|
      # Nullifying awarded_at and outcome_date too because one of the trainees has these dates set incorrectly.
      # Not nullifying recommended_for_award_at and this is set to nil already.
      Trainee.find_by(trn: trn)&.update_columns(state: :trn_received, awarded_at: nil, outcome_date: nil)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
