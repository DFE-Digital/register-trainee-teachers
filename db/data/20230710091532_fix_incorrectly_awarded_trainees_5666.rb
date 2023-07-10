# frozen_string_literal: true

class FixIncorrectlyAwardedTrainees5666 < ActiveRecord::Migration[7.0]
  def up
    %w[9kW3JDjd3XvQ4UQ4Qoig3H7Q
       EQZ3B78pT867gjyvEFWe2ecD
       Bgy75pnatWHNn2VJqa3rubqa
       j1BZfrxA22qu4pkW8Xy3zNsS
       o9TxoTP1ZytvKn6qNgVNSgDr
       z9yyVAqh9hJpk4yJK7SsqWb1
       j4Nh24pAzmKabPEkufXcNq4x
       fYXkbTZUcxaW6tkwNzdtoNWC
       8A8YooHgnq2yfZvAWJi6NXNc].each do |slug|
      Trainee.find_by(slug:)&.update!(state: :trn_received, awarded_at: nil, outcome_date: nil, recommended_for_award_at: nil, audit_comment: "Provider awarded the trainee in error")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
