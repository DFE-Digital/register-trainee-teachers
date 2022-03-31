# frozen_string_literal: true

require "rails_helper"

feature "View trainees" do
  context "when trainee belongs to me" do
    background { given_i_am_authenticated }

    scenario "viewing the personal details of a draft trainee" do
      given_a_trainee_exists
      when_i_view_the_trainee_drafts_page
      then_i_see_the_trainee_data_on_the(trainee_drafts_page)
      and_i_click_the_trainee_name_on_the(trainee_drafts_page)
      then_i_should_see_the_trainee_details_on_the(review_draft_page)
    end

    scenario "viewing the personal details of a registered trainee" do
      given_a_trainee_exists(:submitted_with_start_date)
      when_i_view_the_trainee_index_page
      then_i_see_the_trainee_data_on_the(trainee_index_page)
      and_i_click_the_trainee_name_on_the(trainee_index_page)
      then_i_should_see_the_trainee_details_on_the(record_page)
    end

    scenario "viewing the personal details of an inactive but incomplete trainee" do
      given_a_trainee_exists(:awarded, :provider_led_postgrad, degrees: [])
      and_i_visit_the_personal_details
      then_i_should_not_see_any_add_degree_links_on_the(record_page)
    end
  end

  context "when trainee does not belong to me" do
    background { given_i_am_authenticated }

    let(:trainee) { create(:trainee) }

    scenario "viewing the personal details of trainee" do
      and_i_visit_the_trainee
      then_i_should_see_no_access_text
    end
  end

  context "when i am a lead school user", feature_user_can_have_multiple_organisations: true do
    let(:trainee) { create(:trainee, :submitted_for_trn, commencement_date: nil, lead_school: @current_user.lead_schools.first) }

    background { given_i_am_authenticated_as_a_lead_school_user }

    scenario "viewing the personal details of a registered trainee" do
      and_i_visit_the_trainee
      then_i_should_not_see_any_change_links_on_the(record_page)
      and_i_should_not_see_any_action_links
      and_i_should_not_see_any_incomplete_data_prompts_on_the(record_page)
      and_i_visit_the_personal_details
      then_i_should_not_see_any_change_links_on_the(personal_details_page)
      and_i_should_not_see_any_incomplete_data_prompts_on_the(personal_details_page)
    end
  end

private

  def when_i_view_the_trainee_index_page
    trainee_index_page.load
  end

  def when_i_view_the_trainee_drafts_page
    trainee_drafts_page.load
  end

  def then_i_see_the_trainee_data_on_the(expected_page)
    expect(expected_page).to have_trainee_data
  end

  def and_i_click_the_trainee_name_on_the(expected_page)
    expected_page.trainee_name.first.click
  end

  def then_i_should_see_the_trainee_details_on_the(expected_page)
    expect(expected_page).to be_displayed(id: trainee.slug)
  end

  def then_i_should_see_no_access_text
    expect(record_page).to have_text(t("components.page_titles.pages.forbidden"))
  end

  def then_i_should_not_see_any_change_links_on_the(expected_page)
    expect(expected_page).not_to have_link("Change")
  end

  def then_i_should_not_see_any_add_degree_links_on_the(expected_page)
    expect(expected_page).not_to have_link("Add degree details")
  end

  def and_i_should_not_see_any_action_links
    expect(record_page).not_to have_link("delete this record")
    expect(record_page).not_to have_link("withdraw")
    expect(record_page).not_to have_link("reinstate")
    expect(record_page).not_to have_link("defer")
  end

  def and_i_should_not_see_any_incomplete_data_prompts_on_the(expected_page)
    expect(expected_page).not_to have_text(I18n.t("views.missing_data_banner_view.header"))
  end

  def and_i_visit_the_personal_details
    visit trainee_personal_details_path(trainee)
  end

  def and_i_visit_the_trainee
    visit(trainee_path(trainee))
  end
end
