# frozen_string_literal: true

module PageObjects
  class Feedback < PageObjects::Base
    set_url "/feedback"

    element :error_summary, ".govuk-error-summary"
    element :continue_button, "button[type='submit']"
    element :cancel_link, "a", text: "Cancel"
  end

  class FeedbackCheck < PageObjects::Base
    set_url "/feedback/check"

    element :send_feedback_button, "button[type='submit']"
    element :cancel_link, "a", text: "Cancel"
  end

  class FeedbackConfirmation < PageObjects::Base
    set_url "/feedback/confirmation"

    element :return_to_home_link, "a", text: "Return to home page"
  end
end
