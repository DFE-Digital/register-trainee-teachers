module ConfirmDetailsHelper
  def trainee_section_update_path(section_key, trainee)
    routes = {
      "personal-details" => "trainee_personal_details_confirm_path",
      "contact-details" => "trainee_contact_details_confirm_path",
      "degrees" => "trainee_degrees_confirm_path",
      "information-disclosed" => "trainee_diversity_disclosure_confirm_path",
      "disability-disclosure" => "trainee_diversity_disability_disclosure_confirm_path",
      "disabilities" => "trainee_diversity_disability_detail_confirm_path",
    }

    public_send(routes[section_key.dasherize], trainee)
  end
end
