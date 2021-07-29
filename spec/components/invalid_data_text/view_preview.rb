# frozen_string_literal: true

require "govuk/components"

module InvalidDataText
  class ViewPreview < ViewComponent::Preview
    def default
      render View.new(trainee: trainee, form_section: :institution, hint: "I am a very good hint!")
    end

  private

    def trainee
      @trainee ||= Trainee.new(
        id: 1,
        slug: "XXLbvaRY42wP52hWiP78r94m",
        apply_application: apply_application,
      )
    end

    def apply_application
      @apply_application ||= ApplyApplication.new(
        id: 1,
        application: { bob: "bob" }.to_json,
        invalid_data: { "degrees" => { "XXLbvaRY42wP52hWiP78r94m" => { institution: "University of Warwick" } } }.to_json,
        provider: Provider.last,
      )
    end
  end
end
