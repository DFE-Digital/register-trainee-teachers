# frozen_string_literal: true

require "rails_helper"

feature "course details", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
    given_i_visited_the_review_draft_page
  end

  describe "tracking the progress" do
    scenario "renders a 'not started' status when no details provided" do
      review_draft_page.load(id: trainee.slug)
      and_the_section_should_be(not_started)
    end

    scenario "renders an 'in progress' status when details partially provided" do
      when_i_visit_the_course_details_page
      and_i_enter_valid_parameters
      and_i_submit_the_form
      and_i_confirm_my_details(checked: false, section: course_details_section)
      then_i_am_redirected_to_the_review_draft_page
      and_the_section_should_be(in_progress)
    end

    scenario "renders a completed status when valid details provided" do
      when_i_visit_the_course_details_page
      and_i_enter_valid_parameters
      and_i_submit_the_form
      and_i_confirm_my_details(section: course_details_section)
      then_i_am_redirected_to_the_review_draft_page
      and_the_section_should_be(completed)
    end
  end

  describe "editing the course details" do
    scenario "submitting with valid parameters" do
      when_i_visit_the_course_details_page
      and_i_enter_valid_parameters
      and_i_submit_the_form
      and_i_confirm_my_details(checked: false, section: course_details_section)
      then_i_am_redirected_to_the_review_draft_page
      and_the_course_details_are_updated
    end

    scenario "submitting with invalid parameters" do
      when_i_visit_the_course_details_page
      and_i_submit_the_form
      then_i_see_error_messages
    end

    scenario "submitting with a partial date" do
      when_i_visit_the_course_details_page
      and_i_fill_in_start_date_only
      and_i_submit_the_form
      then_start_date_is_still_populated
    end
  end

  def when_i_visit_the_course_details_page
    course_details_page.load(id: trainee.slug)
  end

  def and_i_enter_valid_parameters
    course_details_page.subject.select(template.subject)
    course_details_page.set_date_fields("course_start_date", template.course_start_date.strftime("%d/%m/%Y"))
    course_details_page.set_date_fields("course_end_date", template.course_end_date.strftime("%d/%m/%Y"))
    age_range = Dttp::CodeSets::AgeRanges::MAPPING[template.age_range]

    if age_range[:option] == :main
      course_details_page.public_send("main_age_range_#{template.age_range.parameterize(separator: '_')}").choose
    else
      course_details_page.main_age_range_other.choose
      course_details_page.additional_age_range.select(template.age_range)
    end
  end

  def and_i_submit_the_form
    course_details_page.submit_button.click
  end

  def and_i_visit_the_record_page
    record_page.load(id: trainee.slug)
  end

  def and_the_course_details_are_updated
    when_i_visit_the_course_details_page

    expect(course_details_page.subject.value).to eq(template.subject)
    expect(course_details_page.course_start_date_day.value).to eq(template.course_start_date.day.to_s)
    expect(course_details_page.course_start_date_month.value).to eq(template.course_start_date.month.to_s)
    expect(course_details_page.course_start_date_year.value).to eq(template.course_start_date.year.to_s)
    expect(course_details_page.course_end_date_day.value).to eq(template.course_end_date.day.to_s)
    expect(course_details_page.course_end_date_month.value).to eq(template.course_end_date.month.to_s)
    expect(course_details_page.course_end_date_year.value).to eq(template.course_end_date.year.to_s)

    age_range = Dttp::CodeSets::AgeRanges::MAPPING[template.age_range]

    if age_range[:option] == :main
      expect(course_details_page.public_send("main_age_range_#{template.age_range.parameterize(separator: '_')}")).to be_checked
    else
      expect(course_details_page.main_age_range_other).to be_checked
      expect(course_details_page.additional_age_range.value).to eq(template.age_range)
    end
  end

  def and_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def and_i_fill_in_start_date_only
    course_details_page.set_date_fields("course_start_date", template.course_start_date.strftime("%d/%m/%Y"))
  end

  def then_start_date_is_still_populated
    expect(course_details_page.course_start_date_day.value).to eq(template.course_start_date.day.to_s)
  end

  def then_i_see_error_messages
    translation_key_prefix = "activemodel.errors.models.course_details_form.attributes"

    expect(page).to have_content(
      I18n.t("#{translation_key_prefix}.subject.blank"),
    )
    expect(page).to have_content(
      I18n.t("#{translation_key_prefix}.main_age_range.blank"),
    )
    expect(page).to have_content(
      I18n.t("#{translation_key_prefix}.course_start_date.blank"),
    )
  end

  def then_i_see_a_flash_message
    expect(page).to have_text("Trainee course details updated")
  end

  def template
    @template ||= build(:trainee, :with_course_details)
  end

  def then_i_am_redirected_to_the_confirm_page
    expect(confirm_details_page).to be_displayed(id: trainee.slug, section: course_details_section)
  end

private

  def course_details_section
    "course-details"
  end
end
