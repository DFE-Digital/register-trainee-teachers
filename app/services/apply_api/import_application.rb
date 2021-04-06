# frozen_string_literal: true

module ApplyApi
  class ImportApplication
    include ServicePattern

    def initialize(application:)
      @application = application
      @provider_code = application["attributes"]["course"]["training_provider_code"]
    end

    def call
      return unless provider

      provider.apply_applications.create!(application: application.to_json)
    end

  private

    attr_reader :application, :provider_code

    def provider
      @provider ||= Provider.find_by(code: provider_code)
    end
  end
end
