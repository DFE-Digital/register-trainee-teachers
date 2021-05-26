# frozen_string_literal: true

module Features
  module CourseDetailsSteps
    def and_the_course_details_is_complete
      given_a_course_is_available_for_selection
      review_draft_page.refresh
      review_draft_page.course_details.link.click
      publish_course_details_page.course_options.first.choose
      publish_course_details_page.submit_button.click
      confirm_publish_course_page.confirm_course_button.click
      and_the_course_details_is_marked_completed
    end

    def given_a_course_is_available_for_selection
      trainee = trainee_from_url
      create(:course, accredited_body_code: trainee.provider.code, route: trainee.training_route)
    end

    def and_the_course_details_is_marked_completed
      expect(review_draft_page).to have_course_details_completed
    end
  end
end
