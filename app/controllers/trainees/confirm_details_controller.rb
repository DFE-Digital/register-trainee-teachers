module Trainees
  class ConfirmDetailsController < ApplicationController
    helper_method :trainee_section_key

    def show
      @confirm_detail = ConfirmDetail.new(trainee: trainee)
      @confirmation_component = component_klass(trainee_section_key).new(trainee: trainee)
    end

    def update
      updater_klass(trainee_section_key).call(trainee: trainee, attributes: mark_as_completed_params)
      redirect_to trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def component_klass(key)
      "Trainees::Confirmation::#{key.underscore.camelcase}::View".constantize
    end

    def updater_klass(key)
      "#{key.underscore.camelcase}::Update".constantize
    end

    def trainee_section_key
      request.path.split("/").intersection(trainee_paths).first
    end

    def trainee_paths
      @trainee_paths ||= [
        trainee_personal_details_path,
        trainee_contact_details_path,
      ].map { |path| path.split("/").last }
    end

    def mark_as_completed_params
      params.require(:confirm_detail).permit(:mark_as_completed)
    end
  end
end
