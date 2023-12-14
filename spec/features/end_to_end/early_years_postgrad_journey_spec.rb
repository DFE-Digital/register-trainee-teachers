# frozen_string_literal: true

require "rails_helper"

feature "early_years_postgrad end-to-end journey" do
  background do
    given_i_am_authenticated
    given_there_is_grant_funding_available_for_early_years_postgrad
  end

  scenario "submit for TRN", "feature_routes.early_years_postgrad": true do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    given_i_have_created_an_early_years_postgrad_trainee
    and_the_personal_details_is_complete
    and_the_contact_details_is_complete
    and_the_diversity_information_is_complete
    and_the_degree_details_is_complete
    and_the_ey_course_details_is_complete
    and_the_trainee_id_is_complete
    and_the_placements_details_is_complete
    and_the_funding_details_with_bursary_is_complete
    and_the_draft_record_has_been_reviewed
    and_all_sections_are_complete
    when_i_submit_for_trn
    then_i_am_redirected_to_the_trn_success_page
  end
end
