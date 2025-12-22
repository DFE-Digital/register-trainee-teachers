# frozen_string_literal: true

require "rails_helper"

feature "Recommending for QTS" do
  include TraineeHelper

  scenario "redirects to the 'Recommended for QTS' page" do
    given_i_am_authenticated
    and_a_trainee_exists_ready_for_qts
    when_i_visit_the_trainee_record_page
    and_i_click_on_recommend_for_qts
    and_i_record_the_outcome_date
    and_i_confirm_the_outcome_details
    then_the_trainee_is_recommended_for_qts
    and_the_page_has_the_correct_links
  end

  def then_the_trainee_is_recommended_for_qts
    expect(page).to have_text("#{trainee_name(@trainee)} recommended for QTS")
  end

  def and_a_trainee_exists_ready_for_qts
    given_a_trainee_exists(
      :with_placement_assignment,
      :trn_received,
      :itt_start_date_in_the_past,
      :provider_led_postgrad,
    )
  end

  def when_i_visit_the_trainee_record_page
    visit trainee_path(trainee)
  end

  def and_i_click_on_recommend_for_qts
    click_on "Change status of trainee"
  end

  def and_i_record_the_outcome_date
    outcome_date_edit_page.choose("Today")
    outcome_date_edit_page.continue.click
  end

  def and_i_confirm_the_outcome_details
    confirm_outcome_details_page.record_outcome.click
  end

  def and_the_page_has_the_correct_links
    recommended_for_qts_page.load(trainee_id: trainee.slug)
    expect(recommended_for_qts_page).to have_link("view #{trainee_name(@trainee)}", href: trainee_path(@trainee))
    expect(recommended_for_qts_page).to have_link("view all your records", href: trainees_path)
  end
end
