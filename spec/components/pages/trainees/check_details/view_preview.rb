# frozen_string_literal: true

require "govuk/components"

module Pages
  module Trainees
    module CheckDetails
      class ViewPreview < ViewComponent::Preview
        ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

        def completed_sections
          @trainee = Trainee.new(id: 1000, trainee_id: "trainee_id",
                                 first_names: "first_names",
                                 last_name: "last_name",
                                 address_line_one: "address_line_one",
                                 address_line_two: "address_line_two",
                                 town_city: "town_city",
                                 middle_names: "middle_names",
                                 international_address: "international_address",
                                 ethnic_background: "ethnic_background",
                                 additional_ethnic_background: "additional_ethnic_background",
                                 subject: "subject",
                                 gender: 1,
                                 date_of_birth: Time.zone.now,
                                 locale_code: 1,
                                 postcode: "BN1 1AA",
                                 email: "email@example.com",
                                 programme_start_date: 6.months.ago,
                                 programme_end_date: Time.zone.now,
                                 progress: Progress.new(
                                   personal_details: true,
                                   contact_details: true,
                                   degrees: true,
                                   diversity: true,
                                   programme_details: true,
                                 ),
                                 age_range: 1,
                                 diversity_disclosure: 1,
                                 degrees: [Degree.new(id: 1, locale_code: 1, subject: "subject")])

          render template: "trainees/check_details/show", locals: { "@trainee": @trainee }
        end

        def continue_sections
          @trainee = Trainee.new(id: 1000, trainee_id: "trainee_id",
                                 first_names: "first_names",
                                 last_name: "last_name",
                                 address_line_one: "address_line_one",
                                 address_line_two: "address_line_two",
                                 town_city: "town_city",
                                 postcode: "postcode",
                                 email: "email",
                                 middle_names: "middle_names",
                                 international_address: "international_address",
                                 ethnic_background: "ethnic_background",
                                 additional_ethnic_background: "additional_ethnic_background",
                                 subject: "subject",
                                 degrees: [Degree.new(id: 1)])

          render template: "trainees/check_details/show", locals: { "@trainee": @trainee }
        end

        def start_sections
          @trainee = Trainee.new(id: 1000)

          render template: "trainees/check_details/show", locals: { "@trainee": @trainee }
        end
      end
    end
  end
end
