# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Filtering trainees by cohort" do
  before do
    given_i_am_authenticated
  end

  context "when only current cohort trainees exists" do
    before do
      given_only_current_trainees_exist
      when_i_visit_the_trainee_index_page
    end

    scenario "cannot filter by cohort" do
      then_i_should_not_see_the_cohort_filter
    end
  end

  context "when trainees from all cohorts exists" do
    before do
      given_trainees_from_all_cohorts_exist
      when_i_visit_the_trainee_index_page
    end

    scenario "can filter by cohort" do
      when_i_filter_by_past_cohort
      then_only_past_cohort_trainees_are_visible
    end
  end

  context "when there are no trainees in future cohort" do
    before do
      given_only_past_and_current_trainees_exist
      when_i_visit_the_trainee_index_page
    end

    scenario "cannot filter by future cohort" do
      then_i_should_not_see_the_future_cohort_checkbox
    end
  end

private

  def given_only_current_trainees_exist
    @current_cohort_trainee ||= create(:trainee, :awarded, :current_cohort, provider: current_provider)
  end

  def given_only_past_and_current_trainees_exist
    @past_cohort_trainee ||= create(:trainee, :awarded, :past_cohort, provider: current_provider)
    @current_cohort_trainee ||= create(:trainee, :awarded, :current_cohort, provider: current_provider)
  end

  def given_trainees_from_all_cohorts_exist
    @past_cohort_trainee ||= create(:trainee, :awarded, :past_cohort, provider: current_provider)
    @current_cohort_trainee ||= create(:trainee, :awarded, :current_cohort, provider: current_provider)
    @future_cohort_trainee ||= create(:trainee, :awarded, :future_cohort, provider: current_provider)
  end

  def current_provider
    @current_provider ||= @current_user.organisation
  end

  def when_i_visit_the_trainee_index_page
    trainee_index_page.load
    expect(trainee_index_page).to be_displayed
  end

  def when_i_filter_by_past_cohort
    trainee_index_page.past_cohort_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def then_only_past_cohort_trainees_are_visible
    expect(trainee_index_page).not_to have_text(full_name(@current_cohort_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@future_cohort_trainee))
    expect(trainee_index_page).to have_text(full_name(@past_cohort_trainee))
  end

  def then_i_should_not_see_the_cohort_filter
    expect(trainee_index_page).not_to have_cohort_filter
  end

  def then_i_should_not_see_the_future_cohort_checkbox
    expect(trainee_index_page).not_to have_future_cohort_checkbox
  end

  def full_name(trainee)
    [trainee.first_names, trainee.last_name].join(" ")
  end
end
