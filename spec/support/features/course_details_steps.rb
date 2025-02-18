# frozen_string_literal: true

module Features
  module CourseDetailsSteps
    def and_the_publish_course_details_is_complete
      given_a_course_is_available_for_selection
      review_draft_page.refresh
      review_draft_page.course_details.link.click
      publish_course_details_page.course_options.first.choose
      publish_course_details_page.submit_button.click
      and_i_enter_itt_dates
      and_i_confirm_my_details
      and_the_course_details_is_marked_completed
    end

    def and_the_course_details_is_complete(
      assessment_only: false, early_years_undergrad: false
    )
      given_subject_specialisms_are_available_for_selection
      and_the_course_education_phase_is_completed
      course_details_page.load(id: trainee_from_url.slug)
      unless early_years_undergrad
        course_details_page.subject.select(subject_specialism_name)
        course_details_page.main_age_range_11_to_16.choose
      end
      and_the_course_study_mode_field_is_completed unless assessment_only
      and_the_course_date_fields_are_completed
      and_the_course_details_are_submitted
      and_the_course_details_is_marked_completed
    end

    def and_the_ey_course_details_is_complete(assessment_only: false)
      course_details_page.load(id: trainee_from_url.slug)
      and_the_course_study_mode_field_is_completed unless assessment_only
      and_the_course_date_fields_are_completed
      and_the_course_details_are_submitted
      and_the_course_details_is_marked_completed
    end

    def given_a_course_is_available_for_selection
      trainee = trainee_from_url
      create(:course_with_subjects,
             accredited_body_code: trainee.provider.code,
             route: trainee.training_route,
             published_start_date: 1.month.from_now,
             subject_names: [AllocationSubjects::PRIMARY])
    end

    def given_subject_specialisms_are_available_for_selection
      create(:subject_specialism, name: subject_specialism_name)
    end

    def subject_specialism_name
      @subject_specialism_name ||= PUBLISH_SECONDARY_SUBJECT_SPECIALISM_MAPPING.values.flatten.uniq.sample.capitalize
    end

    def and_the_course_details_is_marked_completed
      expect(review_draft_page).to have_course_details_completed
    end

    def and_the_course_study_mode_field_is_completed
      course_details_page.study_mode_full_time.choose
    end

    def and_the_course_date_fields_are_completed
      course_details_page.set_date_fields(start_date, 1.day.from_now.strftime("%d/%m/%Y"))
      course_details_page.set_date_fields(end_date, 1.year.from_now.strftime("%d/%m/%Y"))
    end

    def and_the_course_education_phase_is_completed
      course_education_phase_page.load(id: trainee_from_url.slug)
      course_education_phase_page.secondary_phase.choose
      course_education_phase_page.submit_button.click
    end

    def and_the_course_details_are_submitted
      course_details_page.submit_button.click
      confirm_details_page.confirm.click
      confirm_details_page.continue_button.click
    end

    def and_i_see_itt_end_date_missing_error
      expect(confirm_publish_course_details_page).to have_content("Expected end date is missing")
    end

    def and_i_click_enter_answer_for_itt_end_date
      Trainee.last.course_subjects.each do |name|
        create(:subject_specialism, name:)
      end
      confirm_publish_course_details_page.enter_an_answer_for_itt_end_date_link.click
    end

    def and_i_submit_the_course_details_form
      course_details_page.submit_button.click
    end

    def valid_date_after_itt_start_date
      Faker::Date.between(from: trainee.itt_start_date, to: Time.zone.today)
    end

    def and_i_enter_itt_dates
      itt_dates_edit_page.set_date_fields(:start_date, itt_start_date.strftime("%d/%m/%Y"))
      itt_dates_edit_page.set_date_fields(:end_date, itt_end_date.strftime("%d/%m/%Y"))
      itt_dates_edit_page.continue.click
    end

    def given_there_is_grant_funding_available_for_early_years_postgrad
      funding = OpenStruct.new(
        training_route: TRAINING_ROUTE_ENUMS[:early_years_postgrad],
        amount: 5_000,
        allocation_subjects: [
          AllocationSubjects::EARLY_YEARS_ITT,
        ],
      )
      [AcademicCycle.current, AcademicCycle.next].each do |academic_cycle|
        funding_method = FundingMethod.find_or_create_by!(training_route: funding.training_route,
                                                          amount: funding.amount,
                                                          funding_type: FUNDING_TYPE_ENUMS[:grant],
                                                          academic_cycle: academic_cycle)

        funding.allocation_subjects.map do |subject|
          allocation_subject = AllocationSubject.find_or_create_by!(name: subject)
          allocation_subject.subject_specialisms.create_or_find_by(name: CourseSubjects::EARLY_YEARS_TEACHING)
          funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
        end
      end
    end

  private

    def start_date
      "itt_start_date"
    end

    def end_date
      "itt_end_date"
    end
  end
end
