# frozen_string_literal: true

module TaskListHelper
  include CourseDetailsHelper
  include DegreesHelper

  def row_helper(trainee, task)
    case task

    when :publish_course_details
      {
        task_name: "Course details",
        path: (trainee.apply_application? ? edit_trainee_apply_applications_course_details_path(trainee) : edit_trainee_publish_course_details_path(trainee)),
        confirm_path: (trainee.apply_application? ? edit_trainee_apply_applications_course_details_path(trainee) : trainee_course_details_confirm_path(trainee)),
        classes: "course-details",
        status: ProgressService.call(
          validator: ValidatePublishCourseForm.new(trainee),
          progress_value: trainee.progress.course_details,
        ).status,
      }

    when :course_details
      {
        task_name: "Course details",
        path: path_for_course_details(trainee),
        confirm_path: (trainee.apply_application? ? edit_trainee_apply_applications_course_details_path(trainee) : trainee_course_details_confirm_path(trainee)),
        classes: "course-details",
        status: ProgressService.call(
          validator: CourseDetailsForm.new(trainee),
          progress_value: trainee.progress.course_details,
        ).status,
      }

    when :training_details
      {
        task_name: "Trainee ID",
        path: edit_trainee_training_details_path(trainee),
        confirm_path: trainee_training_details_confirm_path(trainee),
        classes: "training-details",
        status: ProgressService.call(
          validator: TrainingDetailsForm.new(trainee),
          progress_value: trainee.progress.training_details,
        ).status,
      }

    when :placement_details
      {
        task_name: "Placements",
        path: edit_trainee_placements_details_path(trainee),
        confirm_path: trainee_placements_confirm_path(trainee),
        classes: "placement-details",
        status: ProgressService.call(
          validator: PlacementDetailForm.new(trainee),
          progress_value: trainee.progress.placements,
        ).status,
      }

    when :lead_partner_and_employing_school_details
      {
        task_name: lead_partner_and_employing_school_details_title(trainee.training_route),
        path: edit_trainee_training_partners_details_path(trainee),
        confirm_path: trainee_schools_confirm_path(trainee),
        classes: "school-details",
        status: ProgressService.call(
          validator: Schools::FormValidator.new(trainee, non_search_validation: true),
          progress_value: trainee.progress.schools,
        ).status,
      }

    when :trainee_data
      validator = ApplyApplications::TraineeDataForm.new(trainee)
      {
        task_name: "Trainee data",
        path: edit_trainee_apply_applications_trainee_data_path(trainee),
        confirm_path: edit_trainee_apply_applications_trainee_data_path(trainee),
        classes: "trainee-data",
        status: ProgressService.call(
          validator: validator,
          progress_value: validator.progress,
        ).status,
      }

    when :personal_details
      {
        task_name: "Personal details",
        path: edit_trainee_personal_details_path(trainee),
        confirm_path: trainee_personal_details_confirm_path(trainee),
        classes: "personal-details",
        status: ProgressService.call(
          validator: PersonalDetailsForm.new(trainee),
          progress_value: trainee.progress.personal_details,
        ).status,
      }

    when :contact_details
      {
        task_name: "Contact details",
        path: edit_trainee_contact_details_path(trainee),
        confirm_path: trainee_contact_details_confirm_path(trainee),
        classes: "contact-details",
        status: ProgressService.call(
          validator: ContactDetailsForm.new(trainee),
          progress_value: trainee.progress.contact_details,
        ).status,
      }

    when :diversity_information
      {
        task_name: "Diversity information",
        path: edit_trainee_diversity_disclosure_path(trainee),
        confirm_path: trainee_diversity_confirm_path(trainee),
        classes: "diversity-details",
        status: ProgressService.call(
          validator: Diversities::FormValidator.new(trainee),
          progress_value: trainee.progress.diversity,
        ).status,
      }

    when :degree
      {
        task_name: "Degree",
        path: path_for_degrees(trainee),
        confirm_path: trainee_degrees_confirm_path(trainee),
        status: ProgressService.call(
          validator: DegreesForm.new(trainee),
          progress_value: trainee.progress.degrees,
        ).status,
        classes: "degree-details",
      }

    when :funding_active
      {
        task_name: "Funding",
        path: edit_trainee_funding_training_initiative_path(trainee),
        confirm_path: trainee_funding_confirm_path(trainee),
        status: ProgressService.call(
          validator: Funding::FormValidator.new(trainee),
          progress_value: trainee.progress.funding,
        ).status,
        classes: "funding",
      }

    when :funding_inactive
      {
        task_name: "Funding",
        path: nil,
        confirm_path: nil,
        status: "cannot_start_yet",
        classes: "funding",
        hint_text: "Complete course details first",
        active: false,
      }

    when :iqts_country_details
      {
        task_name: "International training details",
        path: edit_trainee_iqts_country_path(trainee),
        confirm_path: trainee_iqts_country_confirm_path(trainee),
        status: ProgressService.call(
          validator: IqtsCountryForm.new(trainee),
          progress_value: trainee.progress.iqts_country,
        ).status,
        classes: "iqts-country-details",
      }

    end
  end

private

  def lead_partner_and_employing_school_details_title(route)
    I18n.t("components.review_draft.draft.schools.titles.#{route}")
  end
end
