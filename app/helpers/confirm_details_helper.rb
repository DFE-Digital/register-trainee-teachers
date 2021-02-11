# frozen_string_literal: true

module ConfirmDetailsHelper
  def trainee_section_update_path(section_key, trainee)
    routes = {
      "personal-details" => "trainee_personal_details_confirm_path",
      "contact-details" => "trainee_contact_details_confirm_path",
      "degrees" => "trainee_degrees_confirm_path",
      "programme-details" => "trainee_programme_details_confirm_path",
      "trainee-id" => "trainee_trainee_id_confirm_path",
    }

    public_send(routes[section_key.dasherize], trainee)
  end
end
