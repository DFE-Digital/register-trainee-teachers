# frozen_string_literal: true

require "rails_helper"

feature "provider-led (undergrad) end-to-end journey", type: :feature do
  background { given_i_am_authenticated }

  scenario "submit for TRN", "feature_routes.provider_led_undergrad": true do
    given_i_have_created_a_provider_led_undergrad_trainee
    and_the_personal_details_is_complete
    and_the_contact_details_is_complete
    and_the_diversity_information_is_complete
    and_the_course_details_is_complete
    and_the_trainee_id_is_complete
    and_the_funding_details_is_complete
    and_the_draft_record_has_been_reviewed
    and_all_sections_are_complete
    when_i_submit_for_trn
    then_i_am_redirected_to_the_trn_success_page
  end
end
