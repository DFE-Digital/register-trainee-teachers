# frozen_string_literal: true

# == Schema Information
#
# Table name: trainee_withdrawals
#
#  id              :bigint           not null, primary key
#  another_reason  :string
#  date            :date
#  discarded_at    :datetime
#  future_interest :enum
#  trigger         :enum
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  trainee_id      :bigint           not null
#
# Indexes
#
#  index_trainee_withdrawals_on_discarded_at  (discarded_at)
#  index_trainee_withdrawals_on_trainee_id    (trainee_id)
#
# Foreign Keys
#
#  fk_rails_...  (trainee_id => trainees.id)
#
class TraineeWithdrawal < ApplicationRecord
  belongs_to :trainee
  has_many :trainee_withdrawal_reasons, dependent: :destroy
  has_many :withdrawal_reasons, through: :trainee_withdrawal_reasons

  enum :trigger, { provider: "provider", trainee: "trainee" }, prefix: :triggered_by
  enum :future_interest, { yes: "yes", no: "no", unknown: "unknown" }, suffix: true
end
