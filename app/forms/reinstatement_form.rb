# frozen_string_literal: true

class ReinstatementForm < MultiDateForm
  def save!
    if valid?
      update_trainee
      trainee.save!
      clear_stash
    else
      false
    end
  end

private

  def update_trainee
    trainee[date_field] = date
    trainee.commencement_date = date if trainee.deferred? && trainee.commencement_date.nil?
  end

  def date_field
    @date_field ||= :reinstate_date
  end
end
