# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Filtering trainees" do
  before do
    given_i_am_authenticated
    given_trainees_exist_in_the_system
    when_i_visit_the_trainees_page
    then_all_trainees_are_visible
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
    when_i_filter_by_subject("Biology")
    then_only_assessment_only_biology_trainees_are_visible
  end

  scenario "can clear filters" do
    when_i_filter_by_subject("Biology")
    then_only_assessment_only_biology_trainees_are_visible
    when_i_clear_filters
    then_all_trainees_are_visible
  end

  context "searching" do
    before { when_i_search_for(search_term) }

    shared_examples_for "a working search" do
      it "returns the correct trainee" do
        then_only_the_searchable_trainee_is_visible
        then_the_tag_is_visible_for(search_term)
      end
    end

    context "by name" do
      let(:search_term) { @searchable_trainee.first_names }
      it_behaves_like "a working search"
    end

    context "by trn" do
      let(:search_term) { @searchable_trainee.trn }
      it_behaves_like "a working search"
    end

    context "by trainee_id" do
      let(:search_term) { @searchable_trainee.trainee_id }
      it_behaves_like "a working search"
    end
  end

private

  def given_trainees_exist_in_the_system
    @assessment_only_trainee ||= create(:trainee, record_type: "assessment_only")
    @provider_led_trainee ||= create(:trainee, record_type: "provider_led")
    @biology_trainee ||= create(:trainee, subject: "Biology")
    @history_trainee ||= create(:trainee, subject: "History")
    @searchable_trainee ||= create(:trainee, trn: "123")
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

  def when_i_search_for(value)
    trainees_page.text_search.fill_in(with: value)
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
    Trainee.all.each { |trainee| expect(page).to have_text(full_name(trainee)) }
  end

  def then_only_assessment_only_trainees_are_visible
    expect(page).to have_text(full_name(@assessment_only_trainee))
    expect(page).to_not have_text(full_name(@provider_led_trainee))
  end

  def then_only_provider_led_trainees_are_visible
    expect(page).to_not have_text(full_name(@assessment_only_trainee))
    expect(page).to have_text(full_name(@provider_led_trainee))
  end

  def then_only_biology_trainees_are_visible
    expect(page).to have_text(full_name(@biology_trainee))
    expect(page).to_not have_text(full_name(@history_trainee))
  end

  def then_only_assessment_only_biology_trainees_are_visible
    expect(page).to have_text(full_name(@biology_trainee))
    [
      @assessment_only_trainee,
      @provider_led_trainee,
      @history_trainee,
      @searchable_trainee,
    ].each do |trainee|
      expect(page).to_not have_text(full_name(trainee))
    end
  end

  def then_only_the_searchable_trainee_is_visible
    expect(page).to have_text(full_name(@searchable_trainee))
    [
      @assessment_only_trainee,
      @provider_led_trainee,
      @history_trainee,
      @biology_trainee,
    ].each do |trainee|
      expect(page).to_not have_text(full_name(trainee))
    end
  end

  def then_the_tag_is_visible_for(*values)
    values.each do |value|
      expect(trainees_page.filter_tags).to have_text(value)
    end
  end

  def full_name(trainee)
    [trainee.first_names, trainee.last_name].join(" ")
  end
end
