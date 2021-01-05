# frozen_string_literal: true

module Trainees
  class ConfirmDetailsController < ApplicationController
    helper_method :trainee_section_key
    helper_method :confirm_section_title

    def show
      authorize trainee
      @confirm_detail = ConfirmDetailForm.new(mark_as_completed: trainee.progress.public_send(trainee_section_key))
      @confirmation_component = component_klass(trainee_section_key).new(trainee: trainee)
    end

    def update
      authorize trainee
      toggle_trainee_progress_field
      trainee.save!
      flash[:success] = "Trainee #{flash_message_title} updated"
      redirect_to trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def component_klass(key)
      "Trainees::Confirmation::#{key.underscore.camelcase}::View".constantize
    end

    def trainee_section_key
      request.path.split("/").intersection(trainee_paths).first.underscore
    end

    def confirm_section_title
      trainee_section_key.gsub(/_/, " ")
    end

    def flash_message_title
      I18n.t(
        "components.confirmation.flash.#{trainee_section_key}",
        default: confirm_section_title.pluralize,
      )
    end

    def toggle_trainee_progress_field
      trainee.progress.public_send("#{trainee_section_key}=", mark_as_completed_params)
    end

    def trainee_paths
      @trainee_paths ||= [
        trainee_personal_details_path,
        trainee_contact_details_path,
        trainee_degrees_path,
        trainee_diversity_disclosure_path,
        trainee_diversity_disability_disclosure_path,
        trainee_diversity_disability_detail_path,
        trainee_programme_details_path,
      ].map { |path| path.split("/").last }
    end

    def mark_as_completed_params
      mark_as_completed_attributes = params.require(:confirm_detail_form).permit(:mark_as_completed)[:mark_as_completed]

      ActiveModel::Type::Boolean.new.cast(mark_as_completed_attributes)
    end
  end
end
