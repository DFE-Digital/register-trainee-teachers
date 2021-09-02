# frozen_string_literal: true

module ApplyApi
  class ImportApplication
    include ServicePattern

    class ApplyApiMissingDataError < StandardError; end

    def initialize(application_data:)
      @application_data = application_data
    end

    def call
      ApplyApplication.transaction do
        application.update!(application: application_data.to_json, provider_code: provider_code)
        hei_provider? ? application.non_importable_hei! : application.importable!
      end

      application
    end

  private

    attr_reader :application_data

    # This is `ApplyApplication.find` rather than `provider.apply_applications.find`
    # to cover the possibility of an application's provider being updated.
    def application
      @application ||= ApplyApplication.find_or_initialize_by(apply_id: apply_id)
    end

    def provider_code
      course_attributes("training_provider_code")
    end

    def apply_id
      application_data["id"]
    end

    def hei_provider?
      course_attributes("training_provider_type") == "university"
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
