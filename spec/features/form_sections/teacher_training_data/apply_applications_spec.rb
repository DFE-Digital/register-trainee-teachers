# frozen_string_literal: true

require "rails_helper"

feature "apply registrations" do
  include CourseDetailsHelper

  let(:itt_start_date) { Date.new(Settings.current_recruitment_cycle_year, 9, 1) }
  let(:itt_end_date) { itt_start_date + 1.year }

  background do
    given_i_am_authenticated
    and_a_trainee_exists_created_from_apply
    given_i_am_on_the_review_draft_page
  end

  before do
    FormStore.clear_all(trainee.id)
  end

  after do
    FormStore.clear_all(trainee.id)
  end

  describe "with a missing course code against the trainee" do
    let(:subjects) { ["History"] }

    around do |example|
      Timecop.freeze(Settings.current_recruitment_cycle_year, 6, 1) do
        example.run
      end
    end

    scenario "reviewing course", feature_show_draft_trainee_course_year_choice: false, skip: skip_test_due_to_first_day_of_current_academic_year? do
      given_the_trainee_does_not_have_a_course_uuid
      when_i_enter_the_course_details_page
      then_i_am_on_the_publish_course_details_page
    end
  end

  describe "with a course that doesn't require selecting a specialism" do
    let(:subjects) { ["History"] }

    around do |example|
      Timecop.freeze(Settings.current_recruitment_cycle_year, 6, 1) do
        example.run
      end
    end

    scenario "reviewing course" do
      when_i_enter_the_course_details_page
      and_i_confirm_the_course_details
      and_i_enter_itt_dates
      then_i_am_redirected_to_the_apply_applications_confirm_course_page
      and_i_should_see_the_subject_specialism("History")
      and_i_confirm_the_course
      then_i_am_redirected_to_the_review_draft_page
    end

    context "non overlapping `Academic Cycles`", feature_show_draft_trainee_course_year_choice: false do
      around do |example|
        Timecop.freeze(Settings.current_recruitment_cycle_year, 8, 1) do
          example.run
        end
      end

      scenario "changing course with a different route via the confirm course page" do
        given_my_provider_has_courses_for_other_training_routes
        when_i_enter_the_course_details_page
        and_i_confirm_the_course_details
        and_i_enter_itt_dates
        when_i_click_change_course_on_the_confirm_course_page
        and_i_select_a_different_route
        and_i_choose_a_course_on_a_different_route
        and_i_enter_itt_dates
        and_i_confirm_the_course
        then_the_school_direct_training_route_is_the_route
      end
    end
  end

  describe "with a course that requires selecting multiple specialisms" do
    let(:subjects) { ["Art and design"] }

    scenario "selecting specialisms" do
      when_i_enter_the_course_details_page
      and_i_confirm_the_course_details
      and_i_select_a_specialism("Graphic design")
      and_i_enter_itt_dates
      then_i_am_redirected_to_the_apply_applications_confirm_course_page
      and_i_should_see_the_subject_specialism("Graphic design")
    end
  end

  describe "with a course that requires selecting multiple language specialisms" do
    let(:subjects) { ["Modern languages (other)"] }

    scenario "selecting languages" do
      when_i_enter_the_course_details_page
      and_i_confirm_the_course_details
      and_i_choose_my_languages
      and_i_enter_itt_dates
      then_i_am_redirected_to_the_apply_applications_confirm_course_page
      and_i_should_see_the_subject_specialism("Welsh with Portuguese")
    end
  end

private

  def training_route
    # NOTE: `pg_teaching_apprenticeship` has a different journey covered by it's own spec

    (TRAINING_ROUTES_FOR_COURSE.keys - [ReferenceData::TRAINING_ROUTES.pg_teaching_apprenticeship.name]).sample
  end

  def and_a_trainee_exists_created_from_apply
    given_a_trainee_exists(:with_apply_application,
                           :with_related_courses,
                           :with_valid_future_itt_start_date,
                           courses_count: 1,
                           subject_names: subjects,
                           training_route: training_route)

    Course.first.tap do |course|
      trainee.update(course_uuid: course.uuid)
    end
  end

  def given_the_trainee_does_not_have_a_course_uuid
    trainee.update(course_uuid: nil)
  end

  def given_my_provider_has_courses_for_other_training_routes
    other_route = TRAINING_ROUTES_FOR_COURSE.keys.excluding(trainee.training_route).sample
    @other_course = create(:course_with_subjects,
                           accredited_body_code: trainee.provider.code,
                           route: other_route,
                           subject_names: ["Philosophy"])
    @school_direct_course = create(:course_with_subjects,
                                   accredited_body_code: trainee.provider.code,
                                   route: "school_direct_salaried",
                                   subject_names: ["Dance"])
  end

  def then_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def then_i_am_on_the_publish_course_details_page
    expect(publish_course_details_page).to be_displayed(id: trainee.slug)
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

  def and_i_confirm_the_course_details
    apply_registrations_course_details_page.course_options.first.choose
    apply_registrations_course_details_page.continue.click
  end

  def and_i_choose_a_different_course
    apply_registrations_course_details_page.course_options.second.choose
    apply_registrations_course_details_page.continue.click
    publish_course_details_page.course_options.second.choose
    publish_course_details_page.submit_button.click
  end

  def and_i_choose_my_languages
    select("Welsh", from: language_specialism_page.send(:language_select_one)[:id])
    select("Portuguese", from: language_specialism_page.send(:language_select_two)[:id])
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

  def and_the_training_route_matches_the_course_route
    expect(review_draft_page).to have_content(I18n.t("activerecord.attributes.trainee.training_routes.#{@other_course.route}"))
  end

  def when_i_click_change_course_on_the_confirm_course_page
    apply_registrations_confirm_course_page.change_course.click
  end

  def and_i_select_a_different_route
    trainee_edit_training_route_page.training_route_options.find { |o|
      o.input.value.include?("school_direct_salaried")
    }.choose
    trainee_edit_training_route_page.continue_button.click
  end

  def and_i_choose_a_course_on_a_different_route
    publish_course_details_page.course_options.first.choose
    publish_course_details_page.submit_button.click
  end

  def then_the_school_direct_training_route_is_the_route
    expect(review_draft_page).to have_content(I18n.t("activerecord.attributes.trainee.training_routes.#{@school_direct_course.route}"))
  end
end
