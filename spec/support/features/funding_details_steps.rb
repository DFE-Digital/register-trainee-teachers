# frozen_string_literal: true

module Features
  module FundingDetailsSteps
    def and_the_funding_details_is_complete
      review_draft_page.funding_section.link.click
      edit_funding_page.training_initiative_radios.choose("funding-training-initiatives-form-training-initiative-now-teach-field")
      edit_funding_page.continue_button.click
      confirm_funding_page.confirm.check
      confirm_funding_page.continue.click
    end

    def and_the_funding_details_with_bursary_is_complete
      review_draft_page.funding_section.link.click
      edit_funding_page.training_initiative_radios.choose("funding-training-initiatives-form-training-initiative-now-teach-field")
      edit_funding_page.continue_button.click
      bursary_page.bursary_tier.choose
      bursary_page.submit_button.click
      confirm_funding_page.confirm.check
      confirm_funding_page.continue.click
    end
  end
end
