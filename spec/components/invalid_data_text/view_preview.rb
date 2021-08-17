# frozen_string_literal: true

require "govuk/components"

module InvalidDataText
  class ViewPreview < ViewComponent::Preview
    def default
      render View.new(form_section: :institution, hint: "I am a very good hint!", degree_form: degree_form)
    end

  private

    def trainee
      @trainee ||= Trainee.new(
        id: 1,
        apply_application: apply_application,
      )
    end

    def degree
      @degree ||= Degree.new(
        id: 1,
        slug: "XXLbvaRY42wP52hWiP78r94m",
        trainee: trainee,
      )
    end

    def degree_form
      @degree_form ||= OpenStruct.new(
        degree: degree,
        errors: OpenStruct.new(any?: nil),
      )
    end

    def apply_application
      @apply_application ||= ApplyApplication.new(
        id: 1,
        application: { bob: "bob" },
        invalid_data: { "degrees" => { "XXLbvaRY42wP52hWiP78r94m" => { institution: "University of Warwick" } } },
        provider: Provider.last,
      )
    end
  end
end
