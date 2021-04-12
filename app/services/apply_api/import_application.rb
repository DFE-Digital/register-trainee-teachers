# frozen_string_literal: true

module ApplyApi
  class ImportApplication
    include ServicePattern

    def initialize(application:)
      @raw_application = application
    end

    def call
      return unless provider

      application.update!(
        application: raw_application.to_json,
        provider: provider,
      )
    end

  private

    attr_reader :raw_application

    def provider
      @provider ||= Provider.find_by(code: provider_code)
    end

    # This is `ApplyApplication.find` rather than `provider.apply_applications.find`
    # to cover the possibility of an application's provider being updated.
    def application
      @application ||= ApplyApplication.find_or_initialize_by(apply_id: apply_id)
    end

    def provider_code
      @provider_code ||= raw_application["attributes"]["course"]["training_provider_code"]
    end

    def apply_id
      @apply_id ||= raw_application["id"]
    end
  end
end
