# frozen_string_literal: true

require "rails_helper"

feature "View trainees" do
  background { given_i_am_authenticated }

  context "when trainee belongs to me" do
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
  end

  context "when trainee does not belong to me" do
    let(:trainee) { create(:trainee) }

    scenario "viewing the personal details of trainee" do
      and_i_visit_the_trainee
      then_i_should_see_no_access_text
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

  def and_i_visit_the_trainee
    visit(trainee_path(trainee))
  end
end
