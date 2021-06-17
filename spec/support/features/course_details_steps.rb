# frozen_string_literal: true

module Features
  module CourseDetailsSteps
    def and_the_publish_course_details_is_complete
      given_a_course_is_available_for_selection
      review_draft_page.refresh
      review_draft_page.course_details.link.click
      publish_course_details_page.course_options.first.choose
      publish_course_details_page.submit_button.click
      confirm_publish_course_page.confirm_course_button.click
      and_the_course_details_is_marked_completed
    end

    def and_the_course_details_is_complete
      course_details_page.load(id: trainee_from_url.slug)
      course_details_page.subject.select(Dttp::CodeSets::CourseSubjects::MAPPING.keys.first)
      course_details_page.main_age_range_3_to_11.choose
      and_the_course_date_fields_are_completed
      and_the_course_details_are_submitted
      and_the_course_details_is_marked_completed
    end

    def and_the_ey_course_details_is_complete
      course_details_page.load(id: trainee_from_url.slug)
      and_the_course_date_fields_are_completed
      and_the_course_details_are_submitted
      and_the_course_details_is_marked_completed
    end

    def given_a_course_is_available_for_selection
      trainee = trainee_from_url
      create(:course_with_subjects, accredited_body_code: trainee.provider.code, route: trainee.training_route)
    end

    def and_the_course_details_is_marked_completed
      expect(review_draft_page).to have_course_details_completed
    end

    def and_the_course_date_fields_are_completed
      course_details_page.set_date_fields("course_start_date", "11/3/2021")
      course_details_page.set_date_fields("course_end_date", "11/3/2022")
    end

    def and_the_course_details_are_submitted
      course_details_page.submit_button.click
      confirm_details_page.confirm.click
      confirm_details_page.continue_button.click
    end
  end
end
