# frozen_string_literal: true

module Api
  class GuideController < ::ApplicationController
    skip_before_action :authenticate

    def show
    end
  end
end
