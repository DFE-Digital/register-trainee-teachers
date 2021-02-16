# frozen_string_literal: true

module Features
  module PageHelpers
    def trainee_index_page
      @trainee_index_page ||= PageObjects::Trainees::Index.new
    end

    def new_trainee_page
      @new_trainee_page ||= PageObjects::Trainees::New.new
    end

    def training_details_page
      @training_details_page ||= PageObjects::Trainees::TrainingDetails.new
    end

    def confirm_training_details_page
      @confirm_training_details_page ||= PageObjects::Trainees::ConfirmTrainingDetails.new
    end

    def record_page
      @record_page ||= PageObjects::Trainees::Record.new
    end

    def review_draft_page
      @review_draft_page ||= PageObjects::Trainees::ReviewDraft.new
    end

    def confirm_details_page
      @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
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

    def provider_index_page
      @provider_index_page ||= PageObjects::Providers::Index.new
    end

    def sign_in_page
      @sign_in_page ||= PageObjects::SignIn.new
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
      @not_supported_route_page ||= PageObjects::Trainees::NotSupportedRoute.newx
    end

    def deferral_page
      @defer_date_page ||= PageObjects::Trainees::Deferral.new
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

    def programme_details_page
      @programme_details_page ||= PageObjects::Trainees::ProgrammeDetails.new
    end

    def trainee_id_edit_page
      @trainee_id_edit_page ||= PageObjects::Trainees::EditTraineeId.new
    end

    def confirm_trainee_id_page
      @confirm_trainee_id_page ||= PageObjects::Trainees::ConfirmTraineeId.new
    end

    def trainee_start_date_edit_page
      @trainee_id_edit_page ||= PageObjects::Trainees::EditTraineeStartDate.new
    end

    def outcome_date_edit_page
      @outcome_date_page ||= PageObjects::Trainees::EditOutcomeDate.new
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

    def start_page
      @start_page ||= PageObjects::Start.new
    end

    def accessibility_page
      @accessibility_page ||= PageObjects::Accessibility.new
    end

    def cookies_page
      @cookies_page ||= PageObjects::Cookies.new
    end

    def privacy_policy_page
      @privacy_policy_page ||= PageObjects::PrivacyPolicy.new
    end
  end
end
