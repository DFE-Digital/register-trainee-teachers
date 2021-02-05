# frozen_string_literal: true

module Features
  module CommonSteps
    def given_i_visited_the_review_draft_page
      review_draft_page.load(id: trainee.slug)
    end

    def given_i_visited_the_record_page
      record_page.load(id: trainee.slug)
    end

    def given_i_visited_the_diversities_confirm_page_page
      diversities_confirm_page.load(id: trainee.slug)
    end

    def then_i_am_redirected_to_the_diversities_confirm_page_page
      expect(diversities_confirm_page).to be_displayed(id: trainee.slug)
    end
  end
end
