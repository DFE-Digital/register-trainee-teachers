# frozen_string_literal: true

# == Schema Information
#
# Table name: withdrawal_reasons
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_withdrawal_reasons_on_name  (name) UNIQUE
#
class WithdrawalReason < ApplicationRecord
  has_many :trainee_withdrawal_reasons
  has_many :trainee_withdrawals, through: :trainee_withdrawal_reasons
end
