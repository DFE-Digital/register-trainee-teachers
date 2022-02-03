# frozen_string_literal: true

module Features
  module PageHelpers
    def trainee_index_page
      @trainee_index_page ||= PageObjects::Trainees::Index.new
    end

    def trainee_drafts_page
      @trainee_drafts_page ||= PageObjects::Trainees::Drafts.new
    end

    def request_an_account_page
      @request_an_account_page ||= PageObjects::RequestAnAccount.new
    end

    def new_trainee_page
      @new_trainee_page ||= PageObjects::Trainees::New.new
    end

    def trainee_edit_training_route_page
      @trainee_edit_training_route_page = PageObjects::Trainees::EditTrainingRoute.new
    end

    def training_details_page
      @training_details_page ||= PageObjects::Trainees::TrainingDetails.new
    end

    def confirm_training_details_page
      @confirm_training_details_page ||= PageObjects::Trainees::ConfirmTrainingDetails.new
    end

    def confirm_schools_page
      @confirm_schools_page ||= PageObjects::Trainees::ConfirmSchoolDetails.new
    end

    def record_page
      @record_page ||= PageObjects::Trainees::Record.new
    end

    def review_draft_page
      @review_draft_page ||= PageObjects::Trainees::ReviewDraft.new
    end

    def confirm_draft_deletions_page
      @confirm_draft_deletions_page ||= PageObjects::Trainees::ConfirmDraftDeletions.new
    end

    def confirm_trainee_delete_page
      @confirm_page ||= PageObjects::Trainees::ConfirmDelete.new
    end

    def confirm_details_page
      @confirm_details_page ||= PageObjects::Trainees::ConfirmDetails.new
    end

    def disability_disclosure_page
      @disability_disclosure_page ||= PageObjects::Trainees::Diversities::DisabilityDisclosure.new
    end

    def ethnic_background_page
      @ethnic_background_page ||= PageObjects::Trainees::Diversities::EthnicBackground.new
    end

    def ethnic_group_page
      @ethnic_group_page ||= PageObjects::Trainees::Diversities::EthnicGroup.new
    end

    def diversity_disclosure_page
      @diversity_disclosure_page ||= PageObjects::Trainees::Diversities::Disclosure.new
    end

    def diversities_confirm_page
      @diversities_confirm_page ||= PageObjects::Trainees::Diversities::ConfirmDetails.new
    end

    def new_provider_page
      @new_provider_page ||= PageObjects::Providers::New.new
    end

    def providers_index_page
      @provider_index_page ||= PageObjects::Providers::Index.new
    end

    def dttp_providers_index_page
      @dttp_providers_index_page ||= PageObjects::DttpProviders::Index.new
    end

    def schools_index_page
      @schools_index_page ||= PageObjects::Schools::Index.new
    end

    def lead_schools_index_page
      @lead_schools_index_page ||= PageObjects::LeadSchools::Index.new
    end

    def lead_school_show_page
      @lead_school_show_page ||= PageObjects::LeadSchools::Show.new
    end

    def users_index_page
      @users_index_page ||= PageObjects::Users::Index.new
    end

    def users_show_page
      @users_show_page ||= PageObjects::Users::Show.new
    end

    def new_user_page
      @new_user_page ||= PageObjects::Users::New.new
    end

    def show_user_page
      @new_user_page ||= PageObjects::Users::Show.new
    end

    def add_provider_to_user_page
      @add_provider_to_user_page ||= PageObjects::Users::AddProvider.new
    end

    def add_lead_school_to_user_page
      @add_provider_to_user_page ||= PageObjects::Users::AddLeadSchool.new
    end

    def provider_show_page
      @provider_show_page ||= PageObjects::Providers::Show.new
    end

    def provider_dttp_users_index_page
      @provider_dttp_users_index_page ||= PageObjects::Provider::DttpUsers::Index.new
    end

    def validation_errors_index_page
      @validation_errors_index_page ||= PageObjects::ValidationErrors::Index.new
    end

    def sign_in_page
      @sign_in_page ||= PageObjects::SignIn.new
    end

    def not_found_page
      @not_found_page ||= PageObjects::NotFound.new
    end

    def degree_type_page
      @degree_type_page ||= PageObjects::Trainees::DegreeType.new
    end

    def degree_details_page
      @degree_details_page ||= PageObjects::Trainees::NewDegreeDetails.new
    end

    def degrees_confirm_page
      @degrees_confirm_page ||= PageObjects::Trainees::DegreesConfirm.new
    end

    def edit_degree_details_page
      @edit_degree_details_page ||= PageObjects::Trainees::EditDegreeDetails.new
    end

    def disabilities_page
      @disabilities_page ||= PageObjects::Trainees::Diversities::Disabilities.new
    end

    def not_supported_route_page
      @not_supported_route_page ||= PageObjects::Trainees::NotSupportedRoute.new
    end

    def deferral_page
      @deferral_page ||= PageObjects::Trainees::Deferral.new
    end

    def deferral_confirmation_page
      @deferral_confirmation_page ||= PageObjects::Trainees::ConfirmDeferral.new
    end

    def contact_details_page
      @contact_details_page ||= PageObjects::Trainees::ContactDetails.new
    end

    def personal_details_page
      @personal_details_page ||= PageObjects::Trainees::PersonalDetails.new
    end

    def course_education_phase_page
      @course_education_phase_page ||= PageObjects::Trainees::CourseEducationPhase.new
    end

    def course_details_page
      @course_details_page ||= PageObjects::Trainees::CourseDetails.new
    end

    def confirm_course_details_page
      @confirm_course_details_page ||= PageObjects::Trainees::ConfirmCourseDetails.new
    end

    def confirm_publish_course_details_page
      @confirm_publish_course_details_page ||= PageObjects::Trainees::ConfirmPublishCourseDetails.new
    end

    def apply_registrations_course_details_page
      @apply_registrations_course_details_page ||= PageObjects::Trainees::ApplyRegistrations::CourseDetails.new
    end

    def apply_registrations_confirm_course_page
      @apply_registrations_confirm_course_page ||= PageObjects::Trainees::ApplyRegistrations::ConfirmCourse.new
    end

    def publish_course_details_page
      @publish_course_details_page ||= PageObjects::Trainees::PublishCourseDetails.new
    end

    def subject_specialism_page
      @subject_specialism_page ||= PageObjects::Trainees::SubjectSpecialism.new
    end

    def language_specialism_page
      @language_specialism_page ||= PageObjects::Trainees::LanguageSpecialism.new
    end

    def itt_dates_edit_page
      @itt_start_date_edit_page ||= PageObjects::Trainees::EditIttDates.new
    end

    def study_mode_edit_page
      @study_mode_edit_page ||= PageObjects::Trainees::EditStudyMode.new
    end

    def trainee_start_date_edit_page
      @trainee_start_date_edit_page ||= PageObjects::Trainees::EditTraineeStartDate.new
    end

    def trainee_start_status_edit_page
      @trainee_start_status_edit_page ||= PageObjects::Trainees::EditTraineeStartStatus.new
    end

    def outcome_date_edit_page
      @outcome_date_edit_page ||= PageObjects::Trainees::EditOutcomeDate.new
    end

    def confirm_outcome_details_page
      @confirm_outcome_details_page ||= PageObjects::Trainees::ConfirmOutcomeDetails.new
    end

    def trn_success_page
      @trn_success_page ||= PageObjects::Trainees::TrnSuccess.new
    end

    def check_details_page
      @check_details_page ||= PageObjects::Trainees::CheckDetails::Show.new
    end

    def timeline_page
      @timeline_page ||= PageObjects::Trainees::Timeline.new
    end

    def withdrawal_page
      @withdrawal_page ||= PageObjects::Trainees::Withdrawal.new
    end

    def withdrawal_confirmation_page
      @withdrawal_confirmation_page ||= PageObjects::Trainees::ConfirmWithdrawal.new
    end

    def withdrawal_forbidden_page
      @withdrawal_forbidden_page ||= PageObjects::Trainees::WithdrawalForbidden.new
    end

    def reinstatement_page
      @reinstatement_page ||= PageObjects::Trainees::Reinstatement.new
    end

    def reinstatement_confirmation_page
      @reinstatement_confirmation_page ||= PageObjects::Trainees::ConfirmReinstatement.new
    end

    def start_page
      @start_page ||= PageObjects::Start.new
    end

    def lead_schools_search_page
      @lead_schools_search_page ||= PageObjects::Trainees::LeadSchoolsSearch.new
    end

    def employing_schools_search_page
      @employing_schools_search_page ||= PageObjects::Trainees::EmployingSchoolsSearch.new
    end

    def edit_lead_school_page
      @edit_lead_school_page ||= PageObjects::Trainees::EditLeadSchool.new
    end

    def edit_employing_school_page
      @edit_employing_school_page ||= PageObjects::Trainees::EditEmployingSchool.new
    end

    def accessibility_page
      @accessibility_page ||= PageObjects::Accessibility.new
    end

    def recommended_for_qts_page
      @recommended_for_qts_page ||= PageObjects::Trainees::RecommendedForQts.new
    end

    def training_initiative_page
      @training_initiative_page ||= PageObjects::Trainees::Funding::TrainingInitiative.new
    end

    def bursary_page
      @bursary_page ||= PageObjects::Trainees::Funding::Bursary.new
    end

    def edit_funding_page
      @edit_funding_page ||= PageObjects::Trainees::EditTraineeFunding.new
    end

    def confirm_funding_page
      @confirm_funding_page ||= PageObjects::Trainees::ConfirmFunding.new
    end

    def apply_trainee_data_page
      @apply_trainee_data_page ||= PageObjects::Trainees::ApplyRegistrations::TraineeData.new
    end

    def edit_cookie_preferences_page
      @edit_cookie_preferences_page ||= PageObjects::EditCookiePreferences.new
    end

    def privacy_policy_page
      @privacy_policy_page ||= PageObjects::PrivacyPolicy.new
    end

    def start_date_verification_page
      @start_date_verification_page ||= PageObjects::Trainees::StartDateVerification.new
    end

    def delete_forbidden_page
      @delete_forbidden_page ||= PageObjects::Trainees::DeleteForbidden.new
    end

    def incomplete
      progress_with_prefix(I18n.t("incomplete"))
    end

    def in_progress
      progress_with_prefix(I18n.t("in_progress_valid"))
    end

    def completed
      progress_with_prefix(I18n.t("completed"))
    end

    def organisations_index_page
      @organisations_index_page ||= PageObjects::Organisations::Index.new
    end

  private

    def progress_with_prefix(status)
      "Status #{status}"
    end
  end
end
