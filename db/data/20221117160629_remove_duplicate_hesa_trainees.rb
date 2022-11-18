# frozen_string_literal: true

class RemoveDuplicateHesaTrainees < ActiveRecord::Migration[6.1]
  def up
    sql = %(
      SELECT
          t1.hesa_id AS t1_hesa_id,
          t2.hesa_id AS t2_hesa_id
      FROM
          trainees t1 INNER JOIN trainees t2 ON t1.email = t2.email
      WHERE
        t1.hesa_id != t2.hesa_id
        AND t1.updated_at < t2.updated_at
        AND t1.provider_id = t2.provider_id
        AND t1.start_academic_cycle_id = t2.start_academic_cycle_id
    )

    ActiveRecord::Base.connection.execute(sql).each do |row|
      original, duplicate = find_original_and_duplicate(row)

      next if original.hesa_student && duplicate.hesa_student # edge case, needs to be fixed manually by HESA/provider

      if original.trn.nil? && duplicate.trn.present?
        Trainee.with_auditing do
          original.assign_attributes(state: :trn_received, trn: duplicate.trn)
          original.dqt_trn_request = duplicate.dqt_trn_request if original.dqt_trn_request.nil?
          original.save
        end
        original.dqt_trn_request&.received! unless original.dqt_trn_request&.received?
      end

      duplicate.destroy
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def find_original_and_duplicate(row)
    trainee_a = Trainee.find_by(hesa_id: row["t1_hesa_id"])
    trainee_b = Trainee.find_by(hesa_id: row["t2_hesa_id"])

    if trainee_a.hesa_student
      [trainee_a, trainee_b]
    else
      [trainee_b, trainee_a]
    end
  end
end
