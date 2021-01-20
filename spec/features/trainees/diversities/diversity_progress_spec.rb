# frozen_string_literal: true

require "rails_helper"

feature "completing the diversity section", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(diversity_disclosure: nil, ethnic_group: nil, disability_disclosure: nil)
  end

  scenario "renders a 'not started' status when diversity details are not provided" do
    and_i_visit_the_review_draft_page
    then_the_diversity_section_should_be(:not_started)
  end

  scenario "renders an 'in progress' status when diversity information partially provided" do
    given_valid_diversity_information
    when_i_visit_the_diversity_confirmation_page
    and_unconfirm_my_details
    and_i_visit_the_record_page
    and_i_visit_the_review_draft_page
    then_the_diversity_section_should_be(:in_progress)
  end

  scenario "renders a completed status when valid diversity information provided" do
    given_valid_diversity_information
    and_i_visit_the_review_draft_page
    then_the_diversity_section_should_be(:completed)
  end

private

  def given_valid_diversity_information
    @trainee.diversity_disclosure = Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
    @trainee.ethnic_group = Diversities::ETHNIC_GROUP_ENUMS[:asian]
    @trainee.ethnic_background = "some background"
    @trainee.disability_disclosure = Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
    @trainee.disabilities = [create(:disability, name: "deaf")]
    @trainee.progress.diversity = true
    @trainee.save!
  end

  def and_i_visit_the_review_draft_page
    @review_draft_page ||= PageObjects::Trainees::ReviewDraft.new
    @review_draft_page.load(id: @trainee.slug)
    expect(@review_draft_page).to be_displayed(id: @trainee.slug)
  end

  def and_i_visit_the_record_page
    @record_page ||= PageObjects::Trainees::ReviewDraft.new
    @record_page.load(id: @trainee.slug)
    expect(@record_page).to be_displayed(id: @trainee.slug)
  end

  def then_the_diversity_section_should_be(status)
    @review_draft_page ||= PageObjects::Trainees::ReviewDraft.new
    expect(@review_draft_page.diversity_section.status.text).to eq(Progress::STATUSES[status])
  end

  def when_i_visit_the_diversity_confirmation_page
    @confirm_page ||= PageObjects::Trainees::Diversities::ConfirmDetails.new
    @confirm_page.load(id: @trainee.slug, section: "information-disclosed")
  end

  def then_i_am_redirected_to_the_confirm_page
    @confirm_page ||= PageObjects::Trainees::Diversities::ConfirmDetails.new
    expect(@confirm_page).to be_displayed(id: @trainee.slug, section: "information-disclosed")
  end

  def and_unconfirm_my_details
    @confirm_page ||= PageObjects::Trainees::Diversities::ConfirmDetails.new
    @confirm_page.confirm.uncheck
    @confirm_page.submit_button.click
  end
end
