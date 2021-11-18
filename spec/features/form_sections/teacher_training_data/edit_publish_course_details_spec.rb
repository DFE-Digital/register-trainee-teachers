# frozen_string_literal: true

require "rails_helper"

feature "publish course details", type: :feature, feature_publish_course_details: true do
  include CourseDetailsHelper

  let(:subjects) { [] }
  let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:study_mode) { "full_time" }
  let(:itt_end_date) { 1.year.from_now.to_date }

  background do
    given_i_am_authenticated
    given_a_trainee_exists_with_some_courses(with_subjects: subjects, with_training_route: training_route)
    given_i_am_on_the_review_draft_page
  end

  before do
    FormStore.clear_all(trainee.id)
  end

  after do
    FormStore.clear_all(trainee.id)
  end

  describe "tracking the progress" do
    scenario "renders a 'incomplete' status when no details provided" do
      when_i_visit_the_review_draft_page
      then_the_section_should_be(incomplete)
    end

    context "with a course that doesn't require selecting a specialism" do
      let(:subjects) { [AllocationSubjects::HISTORY] }
      let!(:subject_specialism) { create(:subject_specialism, name: subjects[0].downcase) }

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        then_i_should_see_the_subject_described_as("History")
        and_i_see_itt_end_date_missing_error
        and_i_click_enter_answer_for_itt_end_date
        and_i_enter_itt_end_date(itt_end_date)
        and_i_submit_the_course_details_form
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    context "with a language course that doesn't require selecting a specialism" do
      let(:subjects) { [PublishSubjects::FRENCH] }

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        then_i_should_see_the_subject_described_as("French")
        and_i_see_itt_end_date_missing_error
        and_i_click_enter_answer_for_itt_end_date
        and_i_enter_itt_end_date(itt_end_date)
        and_i_submit_the_course_details_form
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    context "with a course that requires selecting a single specialism" do
      let(:subjects) { [AllocationSubjects::COMPUTING] }
      let!(:subject_specialism) { create(:subject_specialism, name: "Computer science".downcase) }

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        and_i_select_a_specialism("Computer science")
        and_i_submit_the_specialism_form
        then_i_should_see_the_subject_described_as("Computer science")
        and_i_see_itt_end_date_missing_error
        and_i_click_enter_answer_for_itt_end_date
        and_i_enter_itt_end_date(itt_end_date)
        and_i_submit_the_course_details_form
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    context "with a course that requires selecting multiple specialisms" do
      let(:subjects) { [AllocationSubjects::COMPUTING, AllocationSubjects::MATHEMATICS] }
      let!(:subject_specialism) { create(:subject_specialism, name: "Applied computing".downcase) }

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        and_i_select_a_specialism("Applied computing")
        and_i_submit_the_specialism_form
        and_i_select_a_specialism("Mathematics")
        and_i_submit_the_specialism_form
        then_i_should_see_the_subject_described_as("Applied computing with mathematics")
        and_i_see_itt_end_date_missing_error
        and_i_click_enter_answer_for_itt_end_date
        and_i_enter_itt_end_date(itt_end_date)
        and_i_submit_the_course_details_form
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    context "with a course that requires selecting language specialisms" do
      let(:subjects) { ["Modern languages (other)"] }
      let!(:subject_specialism1) { create(:subject_specialism, name: "Arabic languages") }
      let!(:subject_specialism2) { create(:subject_specialism, name: "Portuguese language") }
      let!(:subject_specialism3) { create(:subject_specialism, name: "Welsh language") }

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        and_i_select_languages("Arabic languages", "Welsh", "Portuguese")
        and_i_submit_the_language_specialism_form
        then_i_should_see_the_subject_described_as("Arabic languages with Portuguese and Welsh")
        and_i_see_itt_end_date_missing_error
        and_i_click_enter_answer_for_itt_end_date
        and_i_enter_itt_end_date(itt_end_date)
        and_i_submit_the_course_details_form
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    context "with a course that has a mixture of multiple specalism subjects single specialism ones" do
      let(:subjects) do
        [
          AllocationSubjects::MUSIC,
          AllocationSubjects::COMPUTING,
          AllocationSubjects::HISTORY,
        ]
      end
      let!(:subject_specialism1) { create(:subject_specialism, name: "music education and teaching") }
      let!(:subject_specialism2) { create(:subject_specialism, name: "applied computing") }
      let!(:subject_specialism3) { create(:subject_specialism, name: "history") }

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        and_i_select_a_specialism("Applied computing")
        and_i_submit_the_specialism_form
        then_i_should_see_the_subject_described_as("Music education and teaching with applied computing and history")
        and_i_see_itt_end_date_missing_error
        and_i_click_enter_answer_for_itt_end_date
        and_i_enter_itt_end_date(itt_end_date)
        and_i_submit_the_course_details_form
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end
  end

  describe "available courses" do
    scenario "there aren't any courses for the trainee's provider and route" do
      given_there_arent_any_courses
      when_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_course_education_phase_page
    end

    scenario "there are some courses for the trainee's provider and route" do
      when_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_publish_course_details_page
    end
  end

  describe "selecting a course" do
    scenario "not selecting anything" do
      given_a_trainee_exists_with_some_courses
      when_i_visit_the_publish_course_details_page
      and_i_submit_the_form
      then_i_see_an_error_message
    end

    describe "selecting a course with one specialism" do
      let(:subjects) { [AllocationSubjects::MUSIC] }

      before do
        when_i_visit_the_publish_course_details_page
        and_some_courses_for_other_providers_or_routes_exist
        then_i_see_the_route_message
        and_i_only_see_the_courses_for_my_provider_and_route
        when_i_select_a_course
        and_i_submit_the_form
      end

      scenario do
        then_i_see_the_confirm_publish_course_details_page
      end

      context "trainee is on the pg teaching apprenticeship training route", "feature_routes.pg_teaching_apprenticeship": true do
        let(:training_route) { TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] }

        scenario "with valid itt start date" do
          then_i_see_the_itt_start_date_edit_page
          and_i_set_itt_start_date("1/01/2020")
          and_i_continue
          then_i_see_the_confirm_publish_course_details_page
        end

        context "course study_mode is full_time_or_part_time" do
          let(:study_mode) { "full_time_or_part_time" }
          let(:with_valid_itt_start_date) { "with valid itt start date" }

          scenario :with_valid_itt_start_date do
            then_i_see_the_itt_start_date_edit_page
            and_i_set_itt_start_date("9/09/2020")
            and_i_continue
            then_i_see_the_study_mode_edit_page
          end
        end

        scenario :with_valid_itt_start_date do
          then_i_see_the_itt_start_date_edit_page
          and_i_set_itt_start_date("32/01/2020")
          and_i_continue
          then_i_see_the_error_message_for("invalid")
        end

        scenario "without itt start date" do
          then_i_see_the_itt_start_date_edit_page
          and_i_set_itt_start_date(nil)

          and_i_continue
          then_i_see_the_error_message_for("invalid")
        end
      end
    end

    describe "selecting a course with multiple possible specialisms" do
      let(:subjects) { [AllocationSubjects::COMPUTING] }

      scenario do
        when_i_visit_the_publish_course_details_page
        and_some_courses_for_other_providers_or_routes_exist
        and_i_only_see_the_courses_for_my_provider_and_route
        when_i_select_a_course
        and_i_submit_the_form
        then_i_see_the_subject_specialism_page
      end
    end

    scenario "selecting 'Another course not listed'" do
      when_i_visit_the_publish_course_details_page
      and_i_select_another_course_not_listed
      and_i_submit_the_form
      then_i_see_the_course_education_phase_page
      and_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_publish_course_details_page
    end

    describe "selecting a new course from the confirm page" do
      let(:subjects) { [AllocationSubjects::COMPUTING] }

      scenario do
        given_a_course_exists(with_subjects: ["Modern languages (other)"])
        when_i_visit_the_publish_course_details_page
        when_i_select_a_course("Computing")
        and_i_submit_the_form
        and_i_select_a_specialism("Applied computing")
        and_i_submit_the_specialism_form
        then_i_should_see_the_subject_described_as("Applied computing")
        when_i_visit_the_publish_course_details_page
        when_i_select_a_course("Modern languages (other)")
        and_i_submit_the_form
        and_i_select_languages("Arabic languages", "Welsh", "Portuguese")
        and_i_submit_the_language_specialism_form
        then_i_should_see_the_subject_described_as("Arabic languages with Portuguese and Welsh")
      end
    end
  end

  def given_a_trainee_exists_with_some_courses(with_subjects: [], with_training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
    given_a_trainee_exists(:with_related_courses, :with_secondary_education, subject_names: with_subjects, training_route: with_training_route, study_mode: study_mode)
    @matching_courses = trainee.provider.courses.where(route: trainee.training_route)
  end

  def given_a_course_exists(with_subjects: [])
    create_list(:course_with_subjects, 1,
                subject_names: with_subjects,
                accredited_body_code: @trainee.provider.code,
                route: @trainee.training_route)
  end

  def then_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def then_the_link_takes_me_to_the_course_education_phase_page
    expect(review_draft_page.course_details.link[:href]).to eq edit_trainee_course_education_phase_path(trainee)
  end

  def then_the_link_takes_me_to_the_publish_course_details_page
    expect(review_draft_page.course_details.link[:href]).to eq edit_trainee_publish_course_details_path(trainee)
  end

  def when_i_visit_the_publish_course_details_page
    publish_course_details_page.load(id: trainee.slug)
  end

  def and_i_select_a_course(course_title = nil)
    if course_title
      option = publish_course_details_page.course_options.find { |o| o.label.text.include?(course_title) }
      option.choose
    else
      publish_course_details_page.course_options.first.choose
    end
  end

  def and_i_select_languages(*languages)
    options = language_specialism_page.language_specialism_options.select do |option|
      languages.include?(option.label.text)
    end

    options.each { |checkbox| click(checkbox.input) }
  end

  alias_method :when_i_select_a_course, :and_i_select_a_course

  def and_i_submit_the_form
    publish_course_details_page.submit_button.click
  end

  def and_i_submit_the_specialism_form
    subject_specialism_page.submit_button.click
  end

  def and_i_submit_the_language_specialism_form
    language_specialism_page.submit_button.click
  end

  def and_i_confirm_the_course
    confirm_publish_course_details_page.confirm.click
    confirm_publish_course_details_page.continue_button.click
  end

  def and_i_select_another_course_not_listed
    publish_course_details_page.course_options.last.choose
  end

  def and_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def and_i_select_a_specialism(specialism)
    option = subject_specialism_page.specialism_options.find { |o| o.label.text == specialism }
    option.choose
  end

  alias_method :when_i_visit_the_review_draft_page, :and_i_visit_the_review_draft_page

  def then_i_see_an_error_message
    translation_key_prefix = "activemodel.errors.models.publish_course_details_form.attributes"

    expect(publish_course_details_page).to have_content(
      I18n.t("#{translation_key_prefix}.course_uuid.blank"),
    )
  end

  def then_i_see_the_course_education_phase_page
    expect(course_education_phase_page).to be_displayed(id: trainee.slug)
  end

  def given_there_arent_any_courses
    CourseSubject.destroy_all
    Course.destroy_all
  end

  def and_some_courses_for_other_providers_or_routes_exist
    other_route = TRAINING_ROUTES_FOR_COURSE.keys.excluding(trainee.training_route).sample
    create(:course, accredited_body_code: trainee.provider.code, route: other_route)
    create(:course, route: trainee.training_route)
  end

  def and_i_only_see_the_courses_for_my_provider_and_route
    course_codes_on_page = publish_course_details_page.course_options
      .map { |o| o.label.text.match(/\((.{4})\)/) }
      .compact
      .map { |m| m[1] }
      .sort

    expect(@matching_courses.map(&:code).sort).to eq(course_codes_on_page)
  end

  def and_i_set_itt_start_date(date)
    itt_start_date_edit_page.set_date_fields("itt_start_date", date)
  end

  def and_i_continue
    itt_start_date_edit_page.continue.click
  end

  def then_i_see_the_error_message_for(type)
    expect(itt_start_date_edit_page).to have_content(
      I18n.t("activemodel.errors.models.itt_start_date_form.attributes.date.#{type}"),
    )
  end

  def then_i_see_the_route_message
    expected_message = t("views.forms.publish_course_details.route_message", route: route_title(@trainee.training_route))
    expect(publish_course_details_page.route_message.text).to eq(expected_message)
  end

  def then_i_see_the_confirm_publish_course_details_page
    expect(confirm_publish_course_details_page).to be_displayed(trainee_id: trainee.slug)
  end

  def then_i_see_the_study_mode_edit_page
    expect(study_mode_edit_page).to be_displayed(trainee_id: trainee.slug)
  end

  def then_i_see_the_itt_start_date_edit_page
    expect(itt_start_date_edit_page).to be_displayed(trainee_id: trainee.slug)
  end

  def then_i_see_the_subject_specialism_page
    expect(subject_specialism_page).to be_displayed(trainee_id: trainee.slug, position: 1)
  end

  def then_i_see_the_language_specialism_page
    expect(language_specialism_page).to be_displayed(trainee_id: trainee.slug)
  end

  def then_i_should_see_the_subject_described_as(description)
    expect(confirm_publish_course_details_page.subject_description).to eq(description)
  end

  def and_i_see_itt_end_date_missing_error
    expect(confirm_publish_course_details_page).to have_content("ITT end date is missing")
  end

  def and_i_click_enter_answer_for_itt_end_date
    confirm_publish_course_details_page.enter_an_answer_for_course_end_date_link.click
  end

  def and_i_enter_itt_end_date(date)
    course_details_page.subject_primary.click
    course_details_page.set_date_fields("itt_end_date", date.strftime("%d/%m/%Y"))
  end

  def and_i_submit_the_course_details_form
    course_details_page.submit_button.click
  end
end
