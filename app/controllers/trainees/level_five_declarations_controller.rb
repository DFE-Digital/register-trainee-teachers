# frozen_string_literal: true

module Trainees
  class LevelFiveDeclarationsController < BaseController
    def edit
      @level_five_declaration_form = LevelFiveDeclarationForm.new(trainee)
    end

    def update
      @level_five_declaration_form = LevelFiveDeclarationForm.new(trainee, params: level_five_declaration_params)

      if @level_five_declaration_form.stash_or_save!
        redirect_to(trainee_level_five_declaration_confirm_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def level_five_declaration_params
      return { level_five_qualification: nil } if params[:level_five_declaration_form].blank?

      params.expect(level_five_declaration_form: LevelFiveDeclarationForm::FIELDS)
    end
  end
end
