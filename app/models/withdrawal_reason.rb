# frozen_string_literal: true

# == Schema Information
#
# Table name: withdrawal_reasons
#
#  id          :bigint           not null, primary key
#  description :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_withdrawal_reasons_on_name  (name)
#
class WithdrawalReason < ApplicationRecord
end
