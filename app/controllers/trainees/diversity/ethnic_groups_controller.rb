# frozen_string_literal: true

module Trainees
  module Diversity
    class EthnicGroupsController < ApplicationController
      def edit
        authorize trainee
        @ethnic_group = Diversities::EthnicGroupForm.new(trainee: trainee)
      end

      def update
        authorize trainee
        updater = Diversities::EthnicGroups::Update.call(trainee: trainee, attributes: ethnic_group_param)

        if updater.successful?
          redirect_to_relevant_step
        else
          @ethnic_group = updater.ethnic_group
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

      def ethnic_group_param
        return { ethnic_group: nil } if params[:diversities_ethnic_group_form].blank?

        params.require(:diversities_ethnic_group_form).permit(*Diversities::EthnicGroupForm::FIELDS)
      end

      def redirect_to_relevant_step
        if trainee.not_provided_ethnic_group?
          redirect_to(edit_trainee_diversity_disability_disclosure_path(trainee))
        else
          redirect_to(edit_trainee_diversity_ethnic_background_path(trainee))
        end
      end
    end
  end
end
