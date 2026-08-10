# frozen_string_literal: true

module FindAndUseAnApi
  class PublishCatalogueJob < ApplicationJob
    queue_as :default
    retry_on FindAndUseAnApi::Client::HttpError

    def perform
      return unless Settings.fauapi.enabled

      FindAndUseAnApi::PublishCatalogue.call
    end
  end
end
