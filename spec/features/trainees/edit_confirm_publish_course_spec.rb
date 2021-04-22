# frozen_string_literal: true

require "rails_helper"

feature "confirm publish course", type: :feature, feature_publish_course_details: true do
  after do
    FormStore.clear_all(trainee.id)
  end

  background do
    given_i_am_authenticated
    given_a_trainee_exists(:with_related_courses)
    given_a_course_exists
    given_i_visited_the_review_draft_page
  end

  describe "selecting a course" do
    scenario "confirm course" do
      when_i_visit_the_confirm_publish_course_page
      and_i_submit_the_form
      then_i_am_redirected_to_the_review_draft_page
    end
  end

  def then_i_am_redirected_to_the_review_draft_page
    expect(review_draft_page).to be_displayed(id: trainee.slug)
  end

  def when_i_visit_the_confirm_publish_course_page
    confirm_publish_course_page.load(trainee_id: trainee.slug, id: @course.code)
  end

  def and_i_submit_the_form
    confirm_publish_course_page.confirm_course_button.click
  end

  def given_a_course_exists
    @course = trainee.provider.courses.where(route: trainee.training_route).first
  end
end
