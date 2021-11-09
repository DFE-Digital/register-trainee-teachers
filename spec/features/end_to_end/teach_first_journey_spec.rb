# frozen_string_literal: true

require "rails_helper"

feature "teach-first end-to-end journey", type: :feature do
  let(:user) { create(:user, provider: create(:provider, code: TEACH_FIRST_PROVIDER_CODE)) }

  background { given_i_am_authenticated(user: user) }

  scenario "submit for TRN" do
    given_i_have_created_a_teach_first_trainee
    and_the_personal_details_is_complete
    and_the_contact_details_is_complete
    and_the_diversity_information_is_complete
    and_the_degree_details_is_complete
    and_the_course_details_is_complete
    and_the_trainee_id_is_complete
    and_the_funding_details_is_complete
    and_the_draft_record_has_been_reviewed
    and_all_sections_are_complete
    when_i_submit_for_trn
    then_i_am_redirected_to_the_trn_success_page
  end
end
