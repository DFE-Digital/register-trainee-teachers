module Trainees
  module Diversity
    class DisabilityDisclosuresController < ApplicationController
      def edit
        @disability_disclosure = Diversities::DisabilityDisclosure.new(trainee: trainee)
      end

      def update
        updater = Diversities::DisabilityDisclosures::Update.call(
          trainee: trainee,
          attributes: disability_disclosure_params,
        )

        if updater.successful?
          redirect_to(trainee_path(trainee))
        else
          @disability_disclosure = updater.disability_disclosure
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

      def disability_disclosure_params
        return { disability_disclosure: nil } if params[:diversities_disability_disclosure].blank?

        params.require(:diversities_disability_disclosure).permit(*Diversities::DisabilityDisclosure::FIELDS)
      end
    end
  end
end
