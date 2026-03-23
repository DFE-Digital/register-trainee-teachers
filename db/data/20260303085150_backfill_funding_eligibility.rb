# frozen_string_literal: true

class BackfillFundingEligibility < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      # Set from hesa_trainee_details.fund_code
      execute <<~SQL
        UPDATE trainees
        SET funding_eligibility = CASE htd.fund_code
                                    WHEN '7' THEN 'eligible'
                                    WHEN '2' THEN 'not_eligible'
                                  END
        FROM hesa_trainee_details htd
        WHERE htd.trainee_id = trainees.id
          AND htd.fund_code IN ('7', '2')
          AND trainees.funding_eligibility IS NULL
      SQL

      # Fall back to most recent hesa_students.fund_code for trainees still nil
      execute <<~SQL
        UPDATE trainees
        SET funding_eligibility = CASE hs.fund_code
                                    WHEN '7' THEN 'eligible'
                                    WHEN '2' THEN 'not_eligible'
                                  END
        FROM (
          SELECT DISTINCT ON (hesa_id) hesa_id, fund_code
          FROM hesa_students
          WHERE fund_code IN ('7', '2')
          ORDER BY hesa_id, created_at DESC
        ) hs
        WHERE hs.hesa_id = trainees.hesa_id
          AND trainees.funding_eligibility IS NULL
      SQL
    end
  end

  def down
    Trainee.where.not(funding_eligibility: nil).update_all(funding_eligibility: nil)
  end
end
