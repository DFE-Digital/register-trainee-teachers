# frozen_string_literal: true

class BackfillFundingEligibility < ActiveRecord::Migration[8.0]
  def up
    eligible_code = Hesa::CodeSets::FundCodes::ELIGIBLE
    not_eligible_code = Hesa::CodeSets::FundCodes::NOT_ELIGIBLE

    Trainee.imported_from_hesa.find_each do |trainee|
      fund_code = trainee.hesa_trainee_detail&.fund_code

      if fund_code.nil? && trainee.hesa_students.any?
        fund_code = trainee.hesa_students.order(created_at: :desc).first&.fund_code
      end

      next if fund_code.nil?

      funding_eligibility = case fund_code
                            when eligible_code then :eligible
                            when not_eligible_code then :not_eligible
                            end

      trainee.update!(funding_eligibility:) if funding_eligibility
    end
  end

  def down
    Trainee.where.not(funding_eligibility: nil).update_all(funding_eligibility: nil)
  end
end
