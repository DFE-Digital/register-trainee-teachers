module Trainees
  class NotSupportedRoutesController < ApplicationController
    def index
      render "trainees/not_supported_route"
    end
  end
end
