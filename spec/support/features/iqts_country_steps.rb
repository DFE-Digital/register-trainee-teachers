# frozen_string_literal: true

module Features
  module IqtsCountrySteps
    def and_the_iqts_country_is_complete
      review_draft_page.iqts_country_section.link.click
      edit_iqts_country_page.iqts_country.select("France")
      edit_iqts_country_page.continue_button.click
      confirm_iqts_country_page.confirm.check
      confirm_iqts_country_page.continue.click
    end
  end
end
