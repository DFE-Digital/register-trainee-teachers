# frozen_string_literal: true

require "govuk/components"

module Sections
  class ViewPreview < ViewComponent::Preview
    %i[personal_details
       contact_details
       degrees
       diversity
       course_details
       training_details
       schools
       funding
       placements
       trainee_data].each do |section|
      define_method "continue_sections_#{section}" do
        trainee = continue_sections_trainee(section)
        form = Submissions::TrnValidator.new(trainee:)
        render(View.new(trainee: trainee, section: section, form: form, editable: true))
      end

      define_method "continue_sections_#{section}_validated" do
        trainee = continue_sections_trainee(section)
        form = Submissions::TrnValidator.new(trainee:)
        form.validate
        render(View.new(trainee: trainee, section: section, form: form, editable: true))
      end

      define_method "start_sections_#{section}" do
        trainee = start_sections_trainee(section)
        form = Submissions::TrnValidator.new(trainee:)
        render(View.new(trainee: trainee, section: section, form: form, editable: true))
      end

      define_method "start_sections_#{section}_validated" do
        trainee = start_sections_trainee(section)
        form = Submissions::TrnValidator.new(trainee:)
        form.validate
        render(View.new(trainee: trainee, section: section, form: form, editable: true))
      end
    end

  private

    def continue_sections_trainee(section)
      @continue_sections_trainee ||= Trainee.new(
        id: 1000, provider_trainee_id: "trainee_id",
        first_names: "first_names",
        last_name: "last_name",
        email: "email",
        middle_names: "middle_names",
        ethnic_background: "ethnic_background",
        additional_ethnic_background: "additional_ethnic_background",
        course_subject_one: "subject",
        training_route: ReferenceData::TRAINING_ROUTES.find(training_route(section)).name,
        lead_partner_school: School.new(id: 1),
        degrees: [Degree.new(id: 1, locale_code: :uk)],
        training_initiative: ROUTE_INITIATIVES_ENUMS[:now_teach],
        applying_for_bursary: true,
        provider: Provider.new,
        placement_detail: :has_placement_detail
      )
    end

    def start_sections_trainee(section)
      @start_sections_trainee ||= Trainee.new(id: 1000, training_route: ReferenceData::TRAINING_ROUTES.find(training_route(section)).name, provider: Provider.new)
    end

    def training_route(section)
      return :school_direct_salaried if section == :schools

      :assessment_only
    end
  end
end
