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

    def and_the_course_details_is_complete(requires_study_mode: false)
      given_subject_specialisms_are_available_for_selection
      course_details_page.load(id: trainee_from_url.slug)
      course_details_page.subject.select(subject_specialism_name)
      course_details_page.main_age_range_3_to_11.choose
      if requires_study_mode
        and_the_course_study_mode_field_is_completed
      end
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
      create(:course_with_subjects,
             accredited_body_code: trainee.provider.code,
             route: trainee.training_route,
             subject_names: [AllocationSubjects::HISTORY])
    end

    def given_subject_specialisms_are_available_for_selection
      create(:subject_specialism, name: subject_specialism_name)
    end

    def subject_specialism_name
      @subject_specialism_name ||= Dttp::CodeSets::CourseSubjects::MAPPING.keys.sample.capitalize
    end

    def and_the_course_details_is_marked_completed
      expect(review_draft_page).to have_course_details_completed
    end

    def and_the_course_study_mode_field_is_completed
      course_details_page.study_mode_full_time.choose
    end

    def and_the_course_date_fields_are_completed
      course_details_page.set_date_fields(start_date, "11/3/2021")
      course_details_page.set_date_fields(end_date, "11/3/2022")
    end

    def and_the_course_details_are_submitted
      course_details_page.submit_button.click
      confirm_details_page.confirm.click
      confirm_details_page.continue_button.click
    end

  private

    def start_date
      trainee = trainee_from_url
      trainee.itt_route? ? "itt_start_date" : "course_start_date"
    end

    def end_date
      trainee = trainee_from_url
      trainee.itt_route? ? "itt_end_date" : "course_end_date"
    end
  end
end
