# frozen_string_literal: true

module SystemAdmin
  module Providers
    class ConfirmDeletesController < ApplicationController
      def show
        provider
      end

    private

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end
    end
  end
end
