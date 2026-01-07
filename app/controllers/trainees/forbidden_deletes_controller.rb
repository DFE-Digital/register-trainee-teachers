# frozen_string_literal: true

module Trainees
  class ForbiddenDeletesController < BaseController
    def show
      page_tracker.save!
      @trainee_forbidden_deletes_form = TraineeForbiddenDeleteForm.new
    end

    def create
      @trainee_forbidden_deletes_form = TraineeForbiddenDeleteForm.new(forbidden_deletes_params)

      if @trainee_forbidden_deletes_form.valid?
        if @trainee_forbidden_deletes_form.defer?
          redirect_to(trainee_deferral_path(trainee))
        elsif @trainee_forbidden_deletes_form.withdraw?
          redirect_to(trainee_withdrawal_start_path(trainee))
        else
          redirect_to(trainee_path(trainee))
        end
      else
        render(:show)
      end
    end

  private

    def forbidden_deletes_params
      params.expect(trainee_forbidden_delete_form: [:alternative_option])
    end
  end
end
