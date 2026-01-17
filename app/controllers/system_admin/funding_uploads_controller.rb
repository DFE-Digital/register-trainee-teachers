# frozen_string_literal: true

module SystemAdmin
  class FundingUploadsController < ApplicationController
    before_action { require_feature_flag(:funding_uploads) }
    before_action :redirect_if_no_funding_type, only: [:new]

    helper_method :funding_type

    def index
      @training_partner_trainee_summary = FundingUpload.recently_processed_upload_for(:training_partner_trainee_summary)
      @training_partner_payment_schedule = FundingUpload.recently_processed_upload_for(:training_partner_payment_schedule)
      @provider_trainee_summary = FundingUpload.recently_processed_upload_for(:provider_trainee_summary)
      @provider_payment_schedule = FundingUpload.recently_processed_upload_for(:provider_payment_schedule)
    end

    def new
      @funding_upload_form = FundingUploadForm.new
    end

    def create
      @funding_upload_form = FundingUploadForm.new(funding_upload_params)
      if @funding_upload_form.save!
        ProcessFundingCsvJob.perform_later(@funding_upload_form.funding_upload)
        redirect_to(funding_uploads_confirmation_path)
      else
        render(:new)
      end
    end

  private

    def redirect_if_no_funding_type
      redirect_to(funding_uploads_path) unless funding_type
    end

    def funding_type = params[:funding_type] || @funding_upload_form.funding_type

    def funding_upload_params = params.expect(system_admin_funding_upload_form: %i[funding_type month file])
  end
end
