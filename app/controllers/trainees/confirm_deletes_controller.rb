# frozen_string_literal: true

module Trainees
  class ConfirmDeletesController < BaseController
    prepend_before_action :ensure_trainee_is_draft!

    def show; end
  end
end
