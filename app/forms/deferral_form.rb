# frozen_string_literal: true

class DeferralForm < MultiDateForm
private

  def date_field
    @date_field ||= :defer_date
  end

  def form_store_key
    :deferral
  end
end
