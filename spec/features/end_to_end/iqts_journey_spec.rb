# frozen_string_literal: true

require "rails_helper"

feature "iQTS end-to-end journey" do
  background { given_i_am_authenticated }

  include_context "perform enqueued jobs"

  scenario "submit for TRN", "feature_routes.iqts": true do
    given_i_have_created_an_iqts_trainee
    and_the_personal_details_is_complete
    and_the_contact_details_is_complete
    and_the_diversity_information_is_complete
    and_the_degree_details_is_complete
    and_the_course_details_is_complete
    and_the_placements_details_is_complete
    and_the_trainee_id_is_complete
    and_the_lead_partner_section_is_complete
    and_the_iqts_country_is_complete
    and_the_draft_record_has_been_reviewed
    and_all_sections_are_complete
    when_i_submit_for_trn
    then_i_am_redirected_to_the_trn_success_page
  end
end
