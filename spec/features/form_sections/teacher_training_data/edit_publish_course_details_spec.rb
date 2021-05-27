# frozen_string_literal: true

require "rails_helper"

feature "publish course details", type: :feature, feature_publish_course_details: true do
  include CourseDetailsHelper

  after do
    FormStore.clear_all(trainee.id)
  end

  background do
    given_i_am_authenticated
    given_a_trainee_exists(:with_related_courses, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
    given_some_courses_exist
    given_i_am_on_the_review_draft_page
  end

  before do
    FormStore.clear_all(trainee.id)
  end

  after do
    FormStore.clear_all(trainee.id)
  end

  describe "tracking the progress" do
    scenario "renders a 'not started' status when no details provided" do
      when_i_visit_the_review_draft_page
      then_the_section_should_be(not_started)
    end

    scenario "renders a 'completed' status when details fully provided" do
      when_i_visit_the_publish_course_details_page
      and_i_select_a_course
      and_i_submit_the_form
      and_i_confirm_the_course
      and_i_visit_the_review_draft_page
      then_the_section_should_be(completed)
    end
  end

  describe "available courses" do
    scenario "there aren't any courses for the trainee's provider and route" do
      given_there_arent_any_courses
      when_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_course_details_edit_page
    end

    scenario "there are some courses for the trainee's provider and route" do
      when_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_publish_course_details_page
    end
  end

  describe "selecting a course" do
    scenario "not selecting anything" do
      when_i_visit_the_publish_course_details_page
      and_i_submit_the_form
      then_i_see_an_error_message
    end

    scenario "selecting a course" do
      when_i_visit_the_publish_course_details_page
      and_some_courses_for_other_providers_or_routes_exist
      then_i_see_the_route_message
      and_i_only_see_the_courses_for_my_provider_and_route
      when_i_select_a_course
      and_i_submit_the_form
      then_i_see_the_confirm_publish_course_page
    end

    scenario "selecting 'Another course not listed'" do
      when_i_visit_the_publish_course_details_page
      and_i_select_another_course_not_listed
      and_i_submit_the_form
      then_i_see_the_course_details_page
      and_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_course_details_edit_page
    end
  end

  def then_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def then_the_link_takes_me_to_the_course_details_edit_page
    expect(review_draft_page.course_details.link[:href]).to eq edit_trainee_course_details_path(trainee)
  end

  def then_the_link_takes_me_to_the_publish_course_details_page
    expect(review_draft_page.course_details.link[:href]).to eq edit_trainee_publish_course_details_path(trainee)
  end

  def when_i_visit_the_publish_course_details_page
    publish_course_details_page.load(id: trainee.slug)
  end

  def and_i_select_a_course
    publish_course_details_page.course_options.first.choose
  end

  alias_method :when_i_select_a_course, :and_i_select_a_course

  def and_i_submit_the_form
    publish_course_details_page.submit_button.click
  end

  def and_i_confirm_the_course
    confirm_publish_course_page.submit_button.click
  end

  def and_i_select_another_course_not_listed
    publish_course_details_page.course_options.last.choose
  end

  def and_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  alias_method :when_i_visit_the_review_draft_page, :and_i_visit_the_review_draft_page

  def then_i_see_an_error_message
    translation_key_prefix = "activemodel.errors.models.publish_course_details_form.attributes"

    expect(publish_course_details_page).to have_content(
      I18n.t("#{translation_key_prefix}.code.blank"),
    )
  end

  def then_i_see_the_course_details_page
    expect(course_details_page).to be_displayed(id: trainee.slug)
  end

  def given_some_courses_exist
    @matching_courses = trainee.provider.courses.where(route: trainee.training_route)
  end

  def given_there_arent_any_courses
    Course.destroy_all
  end

  def and_some_courses_for_other_providers_or_routes_exist
    other_route = TRAINING_ROUTES_FOR_COURSE.keys.excluding(trainee.training_route).sample
    create(:course, accredited_body_code: trainee.provider.code, route: other_route)
    create(:course, route: trainee.training_route)
  end

  def and_i_only_see_the_courses_for_my_provider_and_route
    course_codes_on_page = publish_course_details_page.course_options
      .map { |o| o.label.text.match(/\((.*)\)/) }
      .compact
      .map { |m| m[1] }
      .sort

    expect(@matching_courses.map(&:code).sort).to eq(course_codes_on_page)
  end

  def then_i_see_the_route_message
    expected_message = t("views.forms.publish_course_details.route_message", route: route_title(@trainee.training_route))
    expect(publish_course_details_page.route_message.text).to eq(expected_message)
  end

  def then_i_see_the_confirm_publish_course_page
    expect(confirm_publish_course_page).to be_displayed(trainee_id: trainee.slug, id: @matching_courses.first.code)
  end
end
