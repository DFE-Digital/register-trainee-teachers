# frozen_string_literal: true

class UpdateIncorrectlyWithdrawnTrainees < ActiveRecord::Migration[6.1]
  FILE = "data/tad_withdrawal_changes_2022-11-09.csv"

  DATE_MAP = {
    "deferred" => :defer_date,
    "withdrawn" => :withdraw_date,
    "awarded" => :awarded_at,
  }.freeze

  def up
    return unless Rails.env.production?
    return unless csv

    csv.each do |row|
      trainee = Trainee.find_by(id: row[:id])
      next unless trainee

      state = row[:state]
      date_field = DATE_MAP[state]

      params = { state: state, date_field => row[date_field] }.compact

      # Clear the extra withdraw fields if the trainee isn't withdrawn.
      if state != "withdrawn"
        params.merge!({ withdraw_reason: nil, additional_withdraw_reason: nil })
      end

      Trainees::Update.call(
        trainee: trainee,
        params: params,
        update_trs: false,
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def csv
    return unless Rails.root.join(FILE).exist?

    @csv ||= CSV.table(Rails.root.join(FILE))
  end
end
