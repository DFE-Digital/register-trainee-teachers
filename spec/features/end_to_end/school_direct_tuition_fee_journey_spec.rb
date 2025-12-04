# frozen_string_literal: true

require "rails_helper"

feature "school-direct-tuition-fee end-to-end journey", skip: "training route is no longer in use" do
  include_context "perform enqueued jobs"

  background { given_i_am_authenticated }

  scenario "submit for TRN", "feature_routes.school_direct_tuition_fee": true do
    given_i_have_created_a_school_direct_tuition_fee_trainee
    and_the_personal_details_is_complete
    and_the_contact_details_is_complete
    and_the_diversity_information_is_complete
    and_the_degree_details_is_complete
    and_the_course_details_is_complete
    and_the_trainee_id_is_complete
    and_the_funding_details_is_complete
    and_the_training_partner_section_is_complete
    and_the_placements_details_is_complete
    and_the_draft_record_has_been_reviewed
    and_all_sections_are_complete
    when_i_submit_for_trn
    then_i_am_redirected_to_the_trn_success_page
  end
end
