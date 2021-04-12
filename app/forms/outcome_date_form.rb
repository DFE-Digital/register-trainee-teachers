# frozen_string_literal: true

class OutcomeDateForm < MultiDateForm
private

  def date_field
    @date_field ||= :outcome_date
  end
end
