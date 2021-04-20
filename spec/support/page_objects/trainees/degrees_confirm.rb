# frozen_string_literal: true

module PageObjects
  module Trainees
    class DegreesConfirm < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/confirm"

      element :page_heading, "h1.govuk-heading-l"
      element :main_content, "#main-content"
      element :delete_degree, "input[value='Delete degree']"
      element :inset_text, ".govuk-inset-text"
    end
  end
end
