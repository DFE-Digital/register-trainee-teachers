# frozen_string_literal: true

module Trainees
  module Diversity
    class DisclosuresController < ApplicationController
      before_action :authorize_trainee

      def edit
        @disclosure_form = Diversities::DisclosureForm.new(trainee)
      end

      def update
        @disclosure_form = Diversities::DisclosureForm.new(trainee, disclosure_params)
        save_strategy = trainee.draft? ? :save! : :stash

        if @disclosure_form.public_send(save_strategy)
          redirect_to_relevant_step
        else
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def disclosure_params
        return { diversity_disclosure: nil } if params[:diversities_disclosure_form].blank?

        params.require(:diversities_disclosure_form).permit(*Diversities::DisclosureForm::FIELDS)
      end

      def redirect_to_relevant_step
        if @disclosure_form.diversity_disclosed?
          redirect_to(edit_trainee_diversity_ethnic_group_path(trainee))
        else
          redirect_to(trainee_diversity_confirm_path(trainee))
        end
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
