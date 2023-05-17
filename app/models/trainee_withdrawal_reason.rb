# frozen_string_literal: true

# == Schema Information
#
# Table name: trainee_withdrawal_reasons
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  trainee_id           :bigint           not null
#  withdrawal_reason_id :bigint           not null
#
# Indexes
#
#  index_trainee_withdrawal_reasons_on_trainee_id            (trainee_id)
#  index_trainee_withdrawal_reasons_on_withdrawal_reason_id  (withdrawal_reason_id)
#  uniq_idx_trainee_withdawal_reasons                        (trainee_id,withdrawal_reason_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (trainee_id => trainees.id)
#  fk_rails_...  (withdrawal_reason_id => withdrawal_reasons.id)
#
class TraineeWithdrawalReason < ApplicationRecord
  belongs_to :trainee
  belongs_to :withdrawal_reason
end
