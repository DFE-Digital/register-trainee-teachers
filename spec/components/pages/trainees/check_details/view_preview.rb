# frozen_string_literal: true

require "govuk/components"

module Pages
  module Trainees
    module CheckDetails
      class ViewPreview < ViewComponent::Preview
        ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

        %i[start_sections
           continue_sections
           confirmations_sections].each do |sections|
          define_method sections do
            @trainee = trainee(sections)

            @form = TrnSubmissionForm.new(trainee: @trainee)
            render template: template, locals: { "@trainee": @trainee, "@form": @form }
          end

          define_method "#{sections}_validated" do
            @trainee = trainee(sections)

            @form = TrnSubmissionForm.new(trainee: @trainee)
            @form.validate
            render template: template, locals: { "@trainee": @trainee, "@form": @form }
          end
        end

      private

        def trainee(section)
          if section == :start_sections
            trainee_with_all_sections_not_started
          elsif section == :continue_sections
            trainee_with_all_sections_in_progress
          else
            trainee_with_all_sections_completed
          end
        end

        def trainee_with_all_sections_not_started
          Trainee.new(id: 1000, training_route: TRAINING_ROUTE_ENUMS[:assessment_only])
        end

        def trainee_with_all_sections_in_progress
          Trainee.new(id: 1000, trainee_id: "trainee_id",
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
                      training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
                      subject: "subject",
                      degrees: [Degree.new(id: 1)])
        end

        def trainee_with_all_sections_completed
          nationalities = [Nationality.first || Nationality.new(id: 1)]

          Trainee.new(id: 1000, trainee_id: "trainee_id",
                      first_names: "first_names",
                      last_name: "last_name",
                      training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
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
                      course_start_date: 6.months.ago,
                      course_end_date: Time.zone.now,
                      nationalities: nationalities,
                      progress: Progress.new(
                        personal_details: true,
                        contact_details: true,
                        degrees: true,
                        diversity: true,
                        course_details: true,
                        training_details: true,
                      ),
                      age_range: 1,
                      diversity_disclosure: 1,
                      degrees: [Degree.new(id: 1, locale_code: 1, subject: "subject")],
                      commencement_date: Time.zone.now)
        end

        def template
          "trainees/check_details/show"
        end
      end
    end
  end
end
