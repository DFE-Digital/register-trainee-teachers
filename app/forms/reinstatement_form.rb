# frozen_string_literal: true

class ReinstatementForm < MultiDateForm
private

  def date_field
    @date_field ||= :reinstate_date
  end
end
