# frozen_string_literal: true

module TraineeHelper
  def trainee_name(trainee)
    [trainee.first_names, trainee.middle_names, trainee.last_name]
      .compact
      .reject(&:empty?)
      .join(" ")
  end

  def view_trainee(trainee)
    if trainee.draft?
      trainee_path(trainee)
    else
      edit_trainee_path(trainee)
    end
  end
end
