# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmDraftDeletions < PageObjects::Base
      set_url "/trainees/{id}/confirm-delete"

      element :delete_this_draft, ".govuk-button--warning"
    end
  end
end
