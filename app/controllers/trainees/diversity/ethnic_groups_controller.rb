# frozen_string_literal: true

module Trainees
  module Diversity
    class EthnicGroupsController < ApplicationController
      before_action :authorize_trainee

      def edit
        @ethnic_group_form = Diversities::EthnicGroupForm.new(trainee)
      end

      def update
        @ethnic_group_form = Diversities::EthnicGroupForm.new(
          trainee,
          params: ethnic_group_param,
          user: current_user,
        )

        save_strategy = trainee.draft? ? :save! : :stash

        if @ethnic_group_form.public_send(save_strategy)
          redirect_to_relevant_step
        else
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def ethnic_group_param
        return { ethnic_group: nil } if params[:diversities_ethnic_group_form].blank?

        params.require(:diversities_ethnic_group_form).permit(*Diversities::EthnicGroupForm::FIELDS)
      end

      def redirect_to_relevant_step
        if @ethnic_group_form.not_provided_ethnic_group?
          if trainee.disability_disclosure.present?
            redirect_to(page_tracker.last_origin_page_path)
          else
            redirect_to(edit_trainee_diversity_disability_disclosure_path(trainee))
          end
        else
          redirect_to(edit_trainee_diversity_ethnic_background_path(trainee))
        end
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
