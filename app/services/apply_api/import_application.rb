# frozen_string_literal: true

module ApplyApi
  class ImportApplication
    include ServicePattern

    class ApplyApiMissingDataError < StandardError; end

    def initialize(application_data:)
      @application_data = application_data
    end

    def call
      return unless provider

      application.update!(application: application_data.to_json, provider: provider, state: state)

      application
    end

  private

    attr_reader :application_data

    def provider
      @provider ||= Provider.find_by(code: provider_code)
    end

    def state
      return :provider_a_hei if provider_a_hei?
      return :duplicate if trainee_already_exists?

      :importable
    end

    # This is `ApplyApplication.find` rather than `provider.apply_applications.find`
    # to cover the possibility of an application's provider being updated.
    def application
      @application ||= ApplyApplication.find_or_initialize_by(apply_id: apply_id)
    end

    def provider_code
      @provider_code ||= course_attributes("training_provider_code")
    end

    def apply_id
      @apply_id ||= application_data["id"]
    end

    def provider_a_hei?
      course_attributes("training_provider_type") == "university"
    end

    def trainee_already_exists?
      Trainee.exists?(first_names: candidate_attribute("first_name"),
                      last_name: candidate_attribute("last_name"),
                      date_of_birth: candidate_attribute("date_of_birth"))
    end

    def course_attributes(attribute_name)
      application_data["attributes"]["course"][attribute_name]
    rescue NoMethodError
      raise ApplyApiMissingDataError, "Apply application_id #{apply_id} could not be imported"
    end

    def candidate_attribute(attribute_name)
      application_data.dig("attributes", "candidate", attribute_name)
    end
  end
end
