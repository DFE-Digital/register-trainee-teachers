# frozen_string_literal: true

module Features
  module DegreeInformationSteps
    def and_the_degree_details_is_complete
      review_draft_page.degree_details.link.click
      degree_type_page.uk_degree.choose
      degree_details_page.continue.click
      and_i_fill_in_the_uk_degree_form
      degree_details_page.continue.click
      and_i_confirm_my_details
      and_the_degree_details_is_marked_completed
    end

    def and_i_fill_in_the_uk_degree_form
      template = build(:degree, :uk_degree_with_details)
      degree_details_page.uk_degree.select(template.uk_degree)
      degree_details_page.subject.select(template.subject)
      degree_details_page.institution.select(template.institution)
      degree_details_page.grade.choose(template.grade.capitalize)
      degree_details_page.graduation_year.fill_in(with: template.graduation_year)
    end

    def and_the_degree_details_is_marked_completed
      expect(review_draft_page).to have_degree_details_completed
    end
  end
end
