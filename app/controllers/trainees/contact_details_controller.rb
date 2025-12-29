# frozen_string_literal: true

module Trainees
  class ContactDetailsController < BaseController
    include Appliable

    def edit
      @contact_details_form = ContactDetailsForm.new(trainee)
    end

    def update
      @contact_details_form = ContactDetailsForm.new(trainee, params: contact_details_params, user: current_user)

      if @contact_details_form.stash_or_save!
        redirect_to(relevant_redirect_path)
      else
        render(:edit)
      end
    end

  private

    def contact_details_params
      params.expect(contact_details_form: ContactDetailsForm::FIELDS)
    end

    def relevant_redirect_path
      draft_apply_application? ? page_tracker.last_origin_page_path : trainee_contact_details_confirm_path(trainee)
    end
  end
end
