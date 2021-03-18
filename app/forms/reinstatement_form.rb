# frozen_string_literal: true

class ReinstatementForm < MultiDateForm
private

  def date_field
    @date_field ||= :reinstate_date
  end

  def form_store_key
    :reinstatement
  end
end
