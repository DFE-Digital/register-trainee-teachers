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

            @form = SubmissionReadyForm.new(trainee: @trainee)
            render template: template, locals: { "@trainee": @trainee, "@form": @form }
          end

          define_method "#{sections}_validated" do
            @trainee = trainee(sections)

            @form = SubmissionReadyForm.new(trainee: @trainee)
            @form.validate
            render template: template, locals: { "@trainee": @trainee, "@form": @form }
          end

          define_method "#{sections}_itt" do
            @trainee = itt_trainee(sections)

            @form = SubmissionReadyForm.new(trainee: @trainee)
            render template: template, locals: { "@trainee": @trainee, "@form": @form }
          end

          define_method "#{sections}_itt_validated" do
            @trainee = itt_trainee(sections)

            @form = SubmissionReadyForm.new(trainee: @trainee)
            @form.validate
            render template: template, locals: { "@trainee": @trainee, "@form": @form }
          end
        end

      private

        def itt_trainee(section)
          return trainee_with_all_sections_incomplete(training_route_enums_key: :pg_teaching_apprenticeship) if section == :start_sections
          return trainee_with_all_sections_in_progress(training_route_enums_key: :pg_teaching_apprenticeship) if section == :continue_sections

          trainee_with_all_sections_completed(training_route_enums_key: :pg_teaching_apprenticeship)
        end

        def trainee(section)
          return trainee_with_all_sections_incomplete if section == :start_sections
          return trainee_with_all_sections_in_progress if section == :continue_sections

          trainee_with_all_sections_completed
        end

        def trainee_with_all_sections_incomplete(training_route_enums_key: :assessment_only)
          Trainee.new(id: 1000, training_route: TRAINING_ROUTE_ENUMS[training_route_enums_key], provider: Provider.new)
        end

        def trainee_with_all_sections_in_progress(training_route_enums_key: :assessment_only)
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
                      training_route: TRAINING_ROUTE_ENUMS[training_route_enums_key],
                      course_subject_one: "subject",
                      degrees: [Degree.new(id: 1, locale_code: :uk)],
                      training_initiative: ROUTE_INITIATIVES_ENUMS[:transition_to_teach],
                      applying_for_bursary: true,
                      provider: Provider.new)
        end

        def trainee_with_all_sections_completed(training_route_enums_key: :assessment_only)
          nationalities = [Nationality.first || Nationality.new(id: 1)]

          Trainee.new(id: 1000, trainee_id: "trainee_id",
                      first_names: "first_names",
                      last_name: "last_name",
                      training_route: TRAINING_ROUTE_ENUMS[training_route_enums_key],
                      address_line_one: "address_line_one",
                      address_line_two: "address_line_two",
                      town_city: "town_city",
                      middle_names: "middle_names",
                      international_address: "international_address",
                      ethnic_background: "ethnic_background",
                      additional_ethnic_background: "additional_ethnic_background",
                      gender: 1,
                      date_of_birth: Time.zone.now,
                      locale_code: 1,
                      postcode: "BN1 1AA",
                      email: "email@example.com",
                      course_min_age: 0,
                      course_max_age: 5,
                      course_subject_one: "subject",
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
                        funding: true,
                      ),
                      diversity_disclosure: 1,
                      degrees: [Degree.new(id: 1, locale_code: 1, subject: "subject")],
                      commencement_date: Time.zone.now,
                      training_initiative: ROUTE_INITIATIVES_ENUMS[:transition_to_teach],
                      applying_for_bursary: true,
                      provider: Provider.new)
        end

        def template
          "trainees/check_details/show"
        end
      end
    end
  end
end
