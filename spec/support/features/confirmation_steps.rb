# frozen_string_literal: true

module Features
  module ConfirmationSteps
    def and_i_see_my_date(date)
      expect(page).to have_text(date_for_summary_view(date))
    end
  end
end
