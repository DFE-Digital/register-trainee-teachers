# frozen_string_literal: true

require "rails_helper"

feature "course details", type: :feature do
  include SummaryHelper

  background { given_i_am_authenticated }

  context "trainee has no existing course details" do
    scenario "submitting with invalid parameters" do
      given_a_trainee_exists
      when_i_visit_the_course_details_page
      and_i_submit_the_form
      then_i_see_error_messages
    end
  end

  context "trainee has existing course details" do
    background do
      given_a_trainee_exists_with_course_details
      given_i_am_on_the_review_draft_page
    end

    context "when the feature flag is turned on", feature_use_subject_specialisms: true do
      scenario "submitting with valid parameters" do
        given_a_subject_specialism_is_available_for_selection
        when_i_visit_the_course_details_page
        and_i_enter_valid_subject_specialism_parameters
        and_i_enter_valid_parameters
        and_i_submit_the_form
        and_the_course_details_are_updated
      end
    end

    describe "tracking the progress" do
      scenario "renders an 'in progress' status when details partially provided" do
        when_i_visit_the_course_details_page
        and_i_enter_valid_dttp_subject_parameters
        and_i_enter_valid_parameters
        and_i_submit_the_form
        and_i_continue_without_confirming_details
        then_i_am_redirected_to_the_review_draft_page
        and_the_section_should_be(in_progress)
        and_the_course_details_are_updated
      end
    end

    describe "editing the course details" do
      scenario "submitting with a partial subject/age range", js: true do
        when_i_visit_the_course_details_page
        and_i_fill_in_subject_without_selecting_a_value(with: "moose")
        and_i_fill_in_additional_age_range_without_selecting_a_value(with: "goose")
        and_i_submit_the_form
        then_subject_is_populated(with: "moose")
        then_additional_age_range_is_populated(with: "goose")
        then_i_see_error_messages_for_partially_submitted_fields
      end

      scenario "clearing previously selected value", js: true do
        given_a_trainee_exists_with_course_details
        when_i_visit_the_course_details_page
        and_i_fill_in_subject_with_a_blank_value
        and_i_submit_the_form
        then_subject_is_populated(with: "")
        then_i_see_error_messages_for_blank_submitted_fields
      end
    end
  end

private

  def when_i_visit_the_course_details_page
    course_details_page.load(id: trainee.slug)
  end

  def and_i_enter_valid_subject_specialism_parameters
    course_details_page.subject.select(@subject_specialism.name.upcase_first)
  end

  def and_i_enter_valid_dttp_subject_parameters
    course_details_page.subject.select(trainee.course_subject_one)
  end

  def and_i_enter_valid_parameters
    course_details_page.set_date_fields("course_start_date", trainee.course_start_date.strftime("%d/%m/%Y"))
    course_details_page.set_date_fields("course_end_date", trainee.course_end_date.strftime("%d/%m/%Y"))

    age_range = Dttp::CodeSets::AgeRanges::MAPPING[trainee.course_age_range]

    if age_range[:option] == :main
      course_details_page.public_send("main_age_range_#{trainee.course_age_range.join('_to_')}").choose
    else
      course_details_page.main_age_range_other.choose
      course_details_page.additional_age_range.select(trainee.course_age_range.join(" to "))
    end
  end

  def and_i_submit_the_form
    course_details_page.submit_button.click
  end

  def and_the_course_details_are_updated
    when_i_visit_the_course_details_page

    expect(course_details_page.subject.value).to eq(trainee.reload.course_subject_one)
    expect(course_details_page.course_start_date_day.value).to eq(trainee.course_start_date.day.to_s)
    expect(course_details_page.course_start_date_month.value).to eq(trainee.course_start_date.month.to_s)
    expect(course_details_page.course_start_date_year.value).to eq(trainee.course_start_date.year.to_s)
    expect(course_details_page.course_end_date_day.value).to eq(trainee.course_end_date.day.to_s)
    expect(course_details_page.course_end_date_month.value).to eq(trainee.course_end_date.month.to_s)
    expect(course_details_page.course_end_date_year.value).to eq(trainee.course_end_date.year.to_s)

    age_range = Dttp::CodeSets::AgeRanges::MAPPING[trainee.course_age_range]

    if age_range[:option] == :main
      expect(course_details_page.public_send("main_age_range_#{trainee.course_age_range.join('_to_')}")).to be_checked
    else
      expect(course_details_page.main_age_range_other).to be_checked
      expect(course_details_page.additional_age_range.value).to eq(age_range_for_summary_view(trainee.course_age_range))
    end
  end

  def and_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def and_i_fill_in_subject_without_selecting_a_value(with:)
    course_details_page.subject_raw.fill_in with: with
  end

  def and_i_fill_in_subject_with_a_blank_value
    and_i_fill_in_subject_without_selecting_a_value(with: " ")
    course_details_page.subject_raw.native.send_key(:backspace)
  end

  def and_i_fill_in_additional_age_range_without_selecting_a_value(with:)
    choose "Other age range", allow_label_click: true
    course_details_page.additional_age_range.fill_in with: with
  end

  def then_additional_age_range_is_populated(with:)
    expect(course_details_page.additional_age_range_raw.value).to eq(with)
  end

  def then_subject_is_populated(with:)
    expect(course_details_page.subject_raw.value).to eq(with)
  end

  def then_start_date_is_still_populated
    expect(course_details_page.course_start_date_day.value).to eq(trainee.course_start_date.day.to_s)
  end

  def then_i_see_error_messages
    translation_key_prefix = "activemodel.errors.models.course_details_form.attributes"

    expect(course_details_page).to have_content(
      I18n.t("#{translation_key_prefix}.course_subject_one.blank"),
    )
    expect(course_details_page).to have_content(
      I18n.t("#{translation_key_prefix}.main_age_range.blank"),
    )
    expect(course_details_page).to have_content(
      I18n.t("#{translation_key_prefix}.course_start_date.blank"),
    )
  end

  def then_i_see_error_messages_for_partially_submitted_fields
    expect(course_details_page).to have_content(
      I18n.t("activemodel.errors.validators.autocomplete.course_subject_one"),
    )
    expect(course_details_page).to have_content(
      I18n.t("activemodel.errors.validators.autocomplete.additional_age_range"),
    )
  end

  def then_i_see_error_messages_for_blank_submitted_fields
    expect(course_details_page).to have_content(
      I18n.t("activemodel.errors.models.course_details_form.attributes.course_subject_one.blank"),
    )
    expect(course_details_page).not_to have_content(
      I18n.t("activemodel.errors.validators.autocomplete.course_subject_one"),
    )
  end

  def given_a_trainee_exists_with_course_details
    given_a_trainee_exists(:with_course_details)
  end

  def given_a_subject_specialism_is_available_for_selection
    @subject_specialism = create(:subject_specialism)
  end

  def then_i_am_redirected_to_the_confirm_page
    expect(confirm_details_page).to be_displayed(id: trainee.slug, section: course_details_section)
  end

  def course_details_section
    "course-details"
  end
end
