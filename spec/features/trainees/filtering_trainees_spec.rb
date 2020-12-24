# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Filtering trainees" do
  before do
    given_i_am_authenticated
    given_trainees_exist_in_the_system
    when_i_visit_the_trainees_page
    then_all_trainees_are_visible
  end

  scenario "can filter by route" do
    when_i_filter_by_route(:assessment_only)
    then_only_assessment_only_trainees_are_visible
    then_the_tag_is_visible_for("Assessment only")
    then_the_checkbox_should_still_be_checked_for("assessment_only")
    when_i_unfilter_by_route("assessment_only")
    then_all_trainees_are_visible
    when_i_filter_by_route("provider_led")
    then_the_tag_is_visible_for("Provider-led")
    then_only_provider_led_trainees_are_visible
    when_i_filter_by_route("assessment_only")
    then_all_trainees_are_visible
    then_the_tag_is_visible_for("Assessment only", "Provider-led")
    when_i_remove_a_tag_for("Assessment only")
    then_only_provider_led_trainees_are_visible
  end

  scenario "can filter by subject" do
    when_i_filter_by_subject("Biology")
    then_only_biology_trainees_are_visible
    then_the_tag_is_visible_for("Biology")
    then_the_select_should_still_show("Biology")
    when_i_remove_a_tag_for("Biology")
    then_all_trainees_are_visible
    when_i_filter_by_subject("All subjects")
    then_all_trainees_are_visible
  end

  scenario "can filter by route and subject" do
    when_i_filter_by_route("assessment_only")
    when_i_filter_by_subject("Biology")
    then_only_assessment_only_biology_trainees_are_visible
  end

  scenario "can clear filters" do
    when_i_filter_by_route("assessment_only")
    then_only_assessment_only_trainees_are_visible
    when_i_clear_filters
    then_all_trainees_are_visible
  end

private

  def given_trainees_exist_in_the_system
    @assessment_only_trainee ||= create(:trainee, record_type: "assessment_only")
    @provider_led_trainee ||= create(:trainee, record_type: "provider_led")
    @biology_trainee ||= create(:trainee, subject: "Biology")
    @history_trainee ||= create(:trainee, subject: "History")
    Trainee.update_all(provider_id: @current_user.provider.id)
  end

  def trainees_page
    @trainees_page ||= PageObjects::Trainees::Index.new
  end

  def when_i_visit_the_trainees_page
    trainees_page.load
    expect(trainees_page).to be_displayed
  end

  def when_i_filter_by_route(value)
    trainees_page.public_send("#{value}_checkbox").set(true)
    trainees_page.apply_filters.click
  end

  def when_i_unfilter_by_route(value)
    trainees_page.public_send("#{value}_checkbox").set(false)
    trainees_page.apply_filters.click
  end

  def when_i_remove_a_tag_for(value)
    click_link(value)
    trainees_page.apply_filters.click
  end

  def when_i_filter_by_subject(value)
    trainees_page.subject.select(value)
    trainees_page.apply_filters.click
  end

  def when_i_clear_filters
    trainees_page.clear_filters_link.click
  end

  def then_the_checkbox_should_still_be_checked_for(value)
    checkbox = trainees_page.public_send("#{value}_checkbox")
    expect(checkbox.checked?).to be(true)
  end

  def then_the_select_should_still_show(value)
    select = trainees_page.subject
    expect(select.value).to eq value
  end

  def then_all_trainees_are_visible
    Trainee.all.each { |trainee| expect(page).to have_text(trainee.first_names) }
  end

  def then_only_assessment_only_trainees_are_visible
    expect(page).to have_text(@assessment_only_trainee.first_names)
    expect(page).to_not have_text(@provider_led_trainee.first_names)
  end

  def then_only_provider_led_trainees_are_visible
    expect(page).to_not have_text(@assessment_only_trainee.first_names)
    expect(page).to have_text(@provider_led_trainee.first_names)
  end

  def then_only_biology_trainees_are_visible
    expect(page).to have_text(@biology_trainee.first_names)
    expect(page).to_not have_text(@history_trainee.first_names)
  end

  def then_only_assessment_only_biology_trainees_are_visible
    expect(page).to have_text(@biology_trainee.first_names)
    [@assessment_only_trainee, @provider_led_trainee, @history_trainee].each do |t|
      expect(page).to_not have_text(t.first_names)
    end
  end

  def then_the_tag_is_visible_for(*values)
    values.each do |value|
      expect(trainees_page.filter_tags).to have_text(value)
    end
  end
end
