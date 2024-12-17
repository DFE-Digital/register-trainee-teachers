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
      @trainee_edit_training_route_page ||= PageObjects::Trainees::EditTrainingRoute.new
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

    def lead_partners_index_page
      @lead_partners_index_page ||= PageObjects::LeadPartners::Index.new
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

    def add_provider_to_user_page
      @add_provider_to_user_page ||= PageObjects::Users::AddProvider.new
    end

    def add_lead_school_to_user_page
      @add_lead_school_to_user_page ||= PageObjects::Users::AddLeadSchool.new
    end

    def user_lead_schools_page
      @user_lead_schools_page ||= PageObjects::Users::LeadSchools.new
    end

    def provider_show_page
      @provider_show_page ||= PageObjects::Providers::Show.new
    end

    def validation_errors_index_page
      @validation_errors_index_page ||= PageObjects::ValidationErrors::Index.new
    end

    def sign_in_page
      @sign_in_page ||= PageObjects::SignIn.new
    end

    def otp_page
      @otp_page ||= PageObjects::Otp.new
    end

    def otp_verification_page
      @otp_verification_page ||= PageObjects::OtpVerification.new
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

    def deferral_page
      @deferral_page ||= PageObjects::Trainees::Deferral.new
    end

    def edit_school_page
      @edit_school_page ||= PageObjects::SystemAdmin::Schools::Edit.new
    end

    def show_school_page
      @show_school_page ||= PageObjects::SystemAdmin::Schools::Show.new
    end

    def confirm_school_details_page
      @confirm_school_details_page ||= PageObjects::SystemAdmin::Schools::ConfirmDetails.new
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

    def course_years_page
      @course_years_page ||= PageObjects::Trainees::CourseYears.new
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

    def trainee_admin_page
      @trainee_admin_page ||= PageObjects::Trainees::Admin.new
    end

    def withdrawal_start_page
      @withdrawal_start_page ||= PageObjects::Trainees::Withdrawal::Start.new
    end

    def withdrawal_date_page
      @withdrawal_date_page ||= PageObjects::Trainees::Withdrawal::Date.new
    end

    def withdrawal_reason_page
      @withdrawal_reason_page ||= PageObjects::Trainees::Withdrawal::Reason.new
    end

    def withdrawal_trigger_page
      @withdrawal_trigger_page ||= PageObjects::Trainees::Withdrawal::Trigger.new
    end

    def withdrawal_future_interest_page
      @withdrawal_future_interest_page ||= PageObjects::Trainees::Withdrawal::FutureInterest.new
    end

    def withdrawal_extra_information_page
      @withdrawal_extra_information_page ||= PageObjects::Trainees::Withdrawal::ExtraInformation.new
    end

    def withdrawal_confirm_detail_page
      @withdrawal_confirm_detail_page ||= PageObjects::Trainees::Withdrawal::ConfirmDetail.new
    end

    def withdrawal_forbidden_page
      @withdrawal_forbidden_page ||= PageObjects::Trainees::WithdrawalForbidden.new
    end

    def show_undo_withdrawal_page
      @show_undo_withdrawal_page ||= PageObjects::Trainees::ShowUndoWithdrawal.new
    end

    def edit_undo_withdrawal_page
      @edit_undo_withdrawal_page ||= PageObjects::Trainees::EditUndoWithdrawal.new
    end

    def undo_withdrawal_confirmation_page
      @undo_withdrawal_confirmation_page ||= PageObjects::Trainees::UndoWithdrawalConfirmation.new
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

    def edit_trainee_employing_school_details_page
      @edit_trainee_employing_school_details_page ||= PageObjects::Trainees::EmployingSchools::Details::Edit.new
    end

    def edit_trainee_lead_partner_details_page
      @edit_trainee_lead_partner_details_page ||= PageObjects::Trainees::LeadPartners::Details::Edit.new
    end

    def lead_partners_search_page
      @lead_partners_search_page ||= PageObjects::Trainees::LeadPartnersSearch.new
    end

    def employing_schools_search_page
      @employing_schools_search_page ||= PageObjects::Trainees::EmployingSchoolsSearch.new
    end

    def edit_lead_partner_page
      @edit_lead_partner_page ||= PageObjects::Trainees::EditLeadPartner.new
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
      @edit_funding_page ||= PageObjects::Trainees::EditFunding.new
    end

    def confirm_funding_page
      @confirm_funding_page ||= PageObjects::Trainees::ConfirmFunding.new
    end

    def edit_iqts_country_page
      @edit_iqts_country_page ||= PageObjects::Trainees::EditIqtsCountry.new
    end

    def confirm_iqts_country_page
      @confirm_iqts_country_page ||= PageObjects::Trainees::ConfirmIqtsCountry.new
    end

    def apply_trainee_data_page
      @apply_trainee_data_page ||= PageObjects::Trainees::ApplyRegistrations::TraineeData.new
    end

    def edit_cookie_preferences_page
      @edit_cookie_preferences_page ||= PageObjects::EditCookiePreferences.new
    end

    def privacy_notice_page
      @privacy_notice_page ||= PageObjects::PrivacyNotice.new
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

    def user_delete_page
      @user_delete_page ||= PageObjects::Users::Delete.new
    end

    def funding_page
      @funding_page ||= PageObjects::Funding::Show.new
    end

    def payment_schedule_page
      @payment_schedule_page ||= PageObjects::Funding::PaymentSchedule.new
    end

    def trainee_summary_page
      @trainee_summary_page ||= PageObjects::Funding::TraineeSummary.new
    end

    def providers_payment_schedule_page
      @providers_payment_schedule_page ||= PageObjects::SystemAdmin::Funding::ProvidersPaymentSchedule.new
    end

    def providers_trainee_summary_page
      @providers_trainee_summary_page ||= PageObjects::SystemAdmin::Funding::LeadSchoolsTraineeSummary.new
    end

    def lead_schools_payment_schedule_page
      @lead_schools_payment_schedule_page ||= PageObjects::SystemAdmin::Funding::LeadSchoolsPaymentSchedule.new
    end

    def lead_schools_trainee_summary_page
      @lead_schools_trainee_summary_page ||= PageObjects::SystemAdmin::Funding::LeadSchoolsTraineeSummary.new
    end

    def admin_dead_jobs_page
      @admin_dead_jobs_page ||= PageObjects::SystemAdmin::DeadJobs::DeadBackgroundJobs.new
    end

    def admin_dead_jobs_dqt_update_trainee
      @admin_dead_jobs_dqt_update_trainee ||= PageObjects::SystemAdmin::DeadJobs::DqtUpdateTrainee.new
    end

    def admin_pending_trns_page
      @admin_pending_trns_page ||= PageObjects::SystemAdmin::PendingTrns::PendingTrnsSummary.new
    end

    def admin_pending_awards_page
      @admin_pending_awards_page ||= PageObjects::SystemAdmin::PendingAwards::PendingAwardsSummary.new
    end

    def admin_users_index_page
      @admin_users_index_page ||= PageObjects::SystemAdmin::Users::Index.new
    end

    def admin_new_user_page
      @admin_new_user_page ||= PageObjects::SystemAdmin::Users::New.new
    end

    def admin_user_edit_page
      @admin_user_edit_page ||= PageObjects::SystemAdmin::Users::Edit.new
    end

    def admin_user_show_page
      @admin_user_show_page ||= PageObjects::SystemAdmin::Users::Show.new
    end

    def admin_user_delete_page
      @admin_user_delete_page ||= PageObjects::SystemAdmin::Users::Delete.new
    end

    def admin_remove_provider_access_page
      @admin_remove_provider_access_page ||= PageObjects::SystemAdmin::Providers::RemoveAccessConfirmation.new
    end

    def admin_remove_lead_partner_access_page
      @admin_remove_lead_partner_access_page ||= PageObjects::SystemAdmin::Partners::RemoveAccessConfirmation.new
    end

    def admin_delete_trainee_reasons_page
      @admin_delete_trainee_reasons_page ||= PageObjects::SystemAdmin::TraineeDeletions::Reasons.new
    end

    def admin_delete_trainee_confirmation_page
      @admin_delete_trainee_confirmation_page ||= PageObjects::SystemAdmin::TraineeDeletions::Confirmation.new
    end

    def admin_uploads_page
      @admin_uploads_index_page ||= PageObjects::SystemAdmin::Uploads::Index.new
    end

    def admin_upload_new_page
      @admin_uploads_new_page ||= PageObjects::SystemAdmin::Uploads::New.new
    end

    def admin_upload_show_page
      @admin_uploads_show_page ||= PageObjects::SystemAdmin::Uploads::Show.new
    end

    def reports_page
      @reports_page ||= PageObjects::Reports::Index.new
    end

    def performance_profiles_page
      @performance_profiles_page ||= PageObjects::Reports::PerformanceProfiles.new
    end

    def recommendations_upload_page
      @recommendations_upload_page ||= PageObjects::RecommendationsUploads::New.new
    end

    def recommendations_upload_show_page
      @recommendations_upload_show_page ||= PageObjects::RecommendationsUploads::Show.new
    end

    def recommendations_checks_show_page
      @recommendations_checks_show_page ||= PageObjects::RecommendationsChecks::Show.new
    end

    def edit_recommendations_upload_page
      @edit_recommendations_upload_page ||= PageObjects::RecommendationsUploads::Edit.new
    end

    def recommendations_upload_fix_errors_page
      @recommendations_upload_fix_errors_page ||= PageObjects::RecommendationsErrors::Show.new
    end

    def recommendations_upload_cancel_page
      @recommendations_upload_cancel_page ||= PageObjects::RecommendationsUploads::Cancel.new
    end

    def recommendations_upload_confirmation_page
      @recommendations_upload_confirmation_page ||= PageObjects::RecommendationsUploads::Confirmation.new
    end

    def hesa_editing_enabled_page
      @hesa_editing_enabled_page ||= PageObjects::Trainees::Hesa::EnableEdits::Show.new
    end

    def interstitials_hesa_defer_page
      @interstitials_hesa_defer_page ||= PageObjects::Interstitials::Defer.new
    end

    def interstitials_hesa_reinstate_page
      @interstitials_hesa_reinstate_page ||= PageObjects::Interstitials::Reinstate.new
    end

  private

    def progress_with_prefix(status)
      "Status #{status}"
    end
  end
end
