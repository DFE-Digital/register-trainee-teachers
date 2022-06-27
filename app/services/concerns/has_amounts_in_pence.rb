# frozen_string_literal: true

module HasAmountsInPence
  extend ActiveSupport::Concern

  def in_pence(amount_string)
    return 0 if amount_string.blank?

    amount_string.gsub(",", "").to_d * 100
  end
end
