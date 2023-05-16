# frozen_string_literal: true

# == Schema Information
#
# Table name: trainee_withdraw_reasons
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  trainee_id         :bigint           not null
#  withdraw_reason_id :bigint           not null
#
# Indexes
#
#  index_trainee_withdraw_reasons_on_trainee_id          (trainee_id)
#  index_trainee_withdraw_reasons_on_withdraw_reason_id  (withdraw_reason_id)
#  uniq_idx_trainee_withdaw_reasons                      (trainee_id,withdraw_reason_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (trainee_id => trainees.id)
#  fk_rails_...  (withdraw_reason_id => withdraw_reasons.id)
#
class TraineeWithdrawReason < ApplicationRecord
  belongs_to :trainee
  belongs_to :withdraw_reason
end
