module ConfirmDetailsHelper
  def trainee_section_confirm_path(section_key, trainee)
    send("trainee_#{section_key}_confirm_path", trainee)
  end
end
