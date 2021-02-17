# frozen_string_literal: true

require "govuk/components"

module Trainees
  module Sections
    class ViewPreview < ViewComponent::Preview
      %i[personal_details
         contact_details
         degrees
         diversity
         programme_details
         training_details].each do |section|
        define_method "continue_sections_#{section}" do
          render(Trainees::Sections::View.new(trainee: continue_sections_trainee, section: section))
        end

        define_method "start_sections_#{section}" do
          render(Trainees::Sections::View.new(trainee: start_sections_trainee, section: section))
        end
      end

    private

      def continue_sections_trainee
        @continue_sections_trainee ||= Trainee.new(id: 1000, trainee_id: "trainee_id",
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
      end

      def start_sections_trainee
        @start_sections_trainee ||= Trainee.new(id: 1000)
      end
    end
  end
end
