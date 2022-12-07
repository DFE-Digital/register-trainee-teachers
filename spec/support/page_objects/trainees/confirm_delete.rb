# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmDelete < PageObjects::Base
      set_url "/trainees/{id}/confirm-delete"

      element :delete_button, "[type='submit']"
    end
  end
end
