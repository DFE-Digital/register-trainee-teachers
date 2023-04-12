# frozen_string_literal: true

module PageObjects
  module Trainees
    module Hesa
      module EnableEdits
        class Show < PageObjects::Base
          set_url "/trainees/{id}/editing-enabled"

          element :return, ".govuk-link", text: "Return to trainee"
        end
      end
    end
  end
end
