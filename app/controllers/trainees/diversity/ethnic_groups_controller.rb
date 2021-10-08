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

        if @ethnic_group_form.stash_or_save!
          redirect_to(relevant_path)
        else
          render(:edit)
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

      def relevant_path
        if @ethnic_group_form.not_provided_ethnic_group?
          if trainee.disability_disclosure.present?
            trainee_diversity_confirm_path(trainee)
          else
            edit_trainee_diversity_disability_disclosure_path(trainee)
          end
        else
          edit_trainee_diversity_ethnic_background_path(trainee)
        end
      end

      def disclosure_form
        @disclosure_form ||= Diversities::DisclosureForm.new(trainee)
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
