module Trainees
  module Diversity
    class DisclosuresController < ApplicationController
      def edit
        @disclosure = Diversities::Disclosure.new(trainee: trainee)
      end

      def update
        updater = Diversities::Disclosures::Update.call(trainee: trainee, attributes: disclosure_param)
        trainee = updater.disclosure.trainee

        if updater.successful?
          redirect_to_relevant_step(trainee)
        else
          @disclosure = updater.disclosure
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

      def disclosure_param
        return { diversity_disclosure: nil } if params[:diversities_disclosure].blank?

        params.require(:diversities_disclosure).permit(:diversity_disclosure)
      end

      def redirect_to_relevant_step(trainee)
        if trainee.diversity_disclosed?
          redirect_to(edit_trainee_diversity_ethnic_group_path(trainee))
        else
          redirect_to(trainee_path(trainee))
        end
      end
    end
  end
end
