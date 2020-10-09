module Trainees
  class ConfirmDetailsController < ApplicationController
    def show
      @confirmation_component = component_klass(*trainee_section_key).new(trainee: trainee)
    end

    def update
      redirect_to trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def component_klass(key)
      "Confirmation::#{key.underscore.camelcase}::View".constantize
    end

    def trainee_section_key
      request.path.split("/").intersection(trainee_paths)
    end

    def trainee_paths
      @trainee_paths ||= [
        trainee_contact_details_path,
      ].map { |path| path.split("/").last }
    end
  end
end
