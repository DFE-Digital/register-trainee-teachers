module Trainees
  module Diversity
    class EthnicGroupsController < ApplicationController
      def edit
        @ethnic_group = Diversities::EthnicGroup.new(trainee: trainee)
      end

      def update
        updater = Diversities::EthnicGroups::Update.call(trainee: trainee, attributes: ethnic_group_param)
        trainee = updater.ethnic_group.trainee

        if updater.successful?
          redirect_to_relevant_step(trainee)
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
        return { ethnic_group: nil } if params[:diversities_ethnic_group].blank?

        params.require(:diversities_ethnic_group).permit(:ethnic_group)
      end

      def redirect_to_relevant_step(trainee)
        if trainee.no_ethnic_group_provided?
          redirect_to(trainee_path(trainee))
        else
          redirect_to(edit_trainee_diversity_ethnic_background_path(trainee))
        end
      end
    end
  end
end
