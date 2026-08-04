# frozen_string_literal: true

module Fauapi
  class PublishCatalogueJob < ApplicationJob
    queue_as :default
    retry_on Fauapi::Client::HttpError

    def perform
      return unless Settings.fauapi.enabled

      Fauapi::PublishCatalogue.call
    end
  end
end
