# frozen_string_literal: true

require "govuk/components"

module Trainees
  module Sections
    class ViewPreview < ViewComponent::Preview
      %i[personal_details
         contact_details
         degrees
         diversity
         course_details
         training_details
         lead_school].each do |section|
        define_method "continue_sections_#{section}" do
          trainee = continue_sections_trainee(section)
          trn_submission_form = TrnSubmissionForm.new(trainee: trainee)
          render(Trainees::Sections::View.new(trainee: trainee, section: section, trn_submission_form: trn_submission_form))
        end

        define_method "continue_sections_#{section}_validated" do
          trainee = continue_sections_trainee(section)
          trn_submission_form = TrnSubmissionForm.new(trainee: trainee)
          trn_submission_form.validate
          render(Trainees::Sections::View.new(trainee: trainee, section: section, trn_submission_form: trn_submission_form))
        end

        define_method "start_sections_#{section}" do
          trainee = start_sections_trainee(section)
          trn_submission_form = TrnSubmissionForm.new(trainee: trainee)
          render(Trainees::Sections::View.new(trainee: trainee, section: section, trn_submission_form: trn_submission_form))
        end

        define_method "start_sections_#{section}_validated" do
          trainee = start_sections_trainee(section)
          trn_submission_form = TrnSubmissionForm.new(trainee: trainee)
          trn_submission_form.validate
          render(Trainees::Sections::View.new(trainee: trainee, section: section, trn_submission_form: trn_submission_form))
        end
      end

    private

      def continue_sections_trainee(section)
        @continue_sections_trainee ||= Trainee.new(
          id: 1000, trainee_id: "trainee_id",
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
          training_route: TRAINING_ROUTE_ENUMS[training_route(section)],
          lead_school: School.new(id: 1),
          degrees: [Degree.new(id: 1)]
        )
      end

      def start_sections_trainee(section)
        @start_sections_trainee ||= Trainee.new(id: 1000, training_route: TRAINING_ROUTE_ENUMS[training_route(section)])
      end

      def training_route(section)
        return :school_direct_salaried if section == :lead_school

        :assessment_only
      end
    end
  end
end
