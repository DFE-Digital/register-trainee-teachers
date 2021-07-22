# frozen_string_literal: true

require "rails_helper"

feature "apply registrations", type: :feature do
  include CourseDetailsHelper

  background do
    given_i_am_authenticated
    and_a_trainee_exists_created_from_apply
    given_i_am_on_the_review_draft_page
    when_i_enter_the_course_details_page
  end

  describe "with a course that doesn't require selecting a specialism" do
    let(:subjects) { [Dttp::CodeSets::AllocationSubjects::HISTORY] }

    scenario "reviewing course" do
      then_i_am_redirected_to_the_apply_applications_confirm_course_page
      and_i_should_see_the_subject_specialism("History")
      and_i_confirm_the_course
      then_i_am_redirected_to_the_review_draft_page
    end
  end

  describe "with a course that requires selecting multiple specialisms" do
    let(:subjects) { [Dttp::CodeSets::AllocationSubjects::ART_AND_DESIGN] }

    scenario "selecting specialisms" do
      then_i_am_on_the_apply_applications_course_details_page
      and_i_start_to_select_my_specialisms
      and_i_select_a_specialism("Graphic design")
      then_i_am_redirected_to_the_apply_applications_confirm_course_page
      and_i_should_see_the_subject_specialism("Graphic design")
    end
  end

  describe "with a course that requires selecting multiple language specialisms" do
    let(:subjects) { ["Modern languages (other)"] }

    scenario "selecting languages" do
      then_i_am_on_the_apply_applications_course_details_page
      and_i_start_to_select_my_specialisms
      and_i_choose_my_languages
      then_i_am_redirected_to_the_apply_applications_confirm_course_page
      and_i_should_see_the_subject_specialism("Modern languages")
    end
  end

private

  def and_a_trainee_exists_created_from_apply
    given_a_trainee_exists(:with_apply_application, :with_related_courses, courses_count: 1, subject_names: subjects)
    trainee.update(course_code: Course.first.code)
  end

  def then_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def then_i_am_on_the_apply_applications_course_details_page
    expect(apply_registrations_course_details_page).to be_displayed(id: trainee.slug)
  end

  def when_i_visit_the_apply_applications_course_details_page
    apply_registrations_course_details_page.load(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_apply_applications_confirm_course_page
    expect(apply_registrations_confirm_course_page).to be_displayed(id: trainee.slug)
  end

  def when_i_enter_the_course_details_page
    review_draft_page.course_details.link.click
  end

  def and_i_start_to_select_my_specialisms
    apply_registrations_course_details_page.select_specialisms_button.click
  end

  def and_i_choose_my_languages
    language_specialism_page.language_specialism_options.first.check
    language_specialism_page.submit_button.click
  end

  def and_i_confirm_the_course
    apply_registrations_confirm_course_page.confirm.uncheck
    apply_registrations_confirm_course_page.submit_button.click
  end

  def and_i_should_see_the_subject_specialism(description)
    expect(apply_registrations_confirm_course_page.subject_description).to eq(description)
  end

  def and_i_select_a_specialism(specialism)
    subject_specialism_page.specialism_options.find { |o| o.label.text == specialism }.choose
    subject_specialism_page.submit_button.click
  end
end
