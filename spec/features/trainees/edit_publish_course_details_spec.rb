# frozen_string_literal: true

require "rails_helper"

feature "publish course details", type: :feature, feature_publish_course_details: true do
  background do
    some_courses_exist
    given_i_am_authenticated
    given_a_trainee_exists
    given_i_visited_the_review_draft_page
  end

  describe "tracking the progress" do
    scenario "renders a 'not started' status when no details provided" do
      review_draft_page.load(id: trainee.slug)
      then_the_section_should_be(not_started)
    end

    scenario "renders an 'in progress' status when details partially provided" do
      when_i_visit_the_publish_course_details_page
      and_i_select_a_course
      and_i_submit_the_form
      and_i_visit_the_review_draft_page
      then_the_section_should_be(in_progress)
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
      and_i_select_a_course
      # TODO: confirm page when it is added
    end

    scenario "selecting 'Another course not listed'" do
      when_i_visit_the_publish_course_details_page
      and_i_select_another_course_not_listed
      and_i_submit_the_form
      then_i_see_the_course_details_page
      and_i_visit_the_review_draft_page
      then_the_link_takes_me_back_to_the_course_details_edit_page
    end
  end

  def then_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def then_the_link_takes_me_back_to_the_course_details_edit_page
    expect(review_draft_page.course_details.link[:href]).to eq edit_trainee_course_details_path(trainee)
  end

  def when_i_visit_the_publish_course_details_page
    publish_course_details_page.load(id: trainee.slug)
  end

  def and_i_select_a_course
    publish_course_details_page.course_options.first.choose
  end

  def and_i_submit_the_form
    publish_course_details_page.submit_button.click
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

  def some_courses_exist
    # TODO: make these match the route of the trainee
    FactoryBot.create_list(:course, 10)
  end
end
