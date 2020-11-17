module Trainees
  module Diversity
    class EthnicBackgroundsController < BaseController
      def edit
        @ethnic_background = Diversities::EthnicBackground.new(trainee: trainee)
      end

      def update
        updater = Diversities::EthnicBackgrounds::Update.call(trainee: trainee, attributes: ethnic_background_param)

        if updater.successful?
          redirect_to(edit_trainee_diversity_disability_disclosure_path(trainee))
        else
          @ethnic_background = updater.ethnic_background
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

      def ethnic_background_param
        return { ethnic_background: nil } if params[:diversities_ethnic_background].blank?

        params.require(:diversities_ethnic_background).permit(
          *Diversities::EthnicBackground::FIELDS,
        )
      end
    end
  end
end
