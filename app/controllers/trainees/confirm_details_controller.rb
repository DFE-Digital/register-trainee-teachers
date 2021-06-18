# frozen_string_literal: true

module Trainees
  class ConfirmDetailsController < ApplicationController
    before_action :authorize_trainee

    helper_method :trainee_section_key
    helper_method :confirm_section_title

    def show
      page_tracker.save_as_origin!

      if trainee.draft?
        @confirm_detail_form = ConfirmDetailForm.new(mark_as_completed: trainee.progress.public_send(trainee_section_key))
      end

      @confirmation_component = component_klass.new(data_model: trainee.draft? ? trainee : form_klass.new(trainee))
    end

    def update
      form_klass.new(trainee).save! unless trainee.draft?

      toggle_trainee_progress_field if trainee.draft?

      flash[:success] = "Trainee #{flash_message_title} updated"

      redirect_to page_tracker.last_origin_page_path || trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def component_klass
      "Confirmation::#{trainee_section_key.underscore.camelcase}::View".constantize
    end

    def form_klass
      case trainee_section_key
      when "schools"
        Schools::FormValidator
      else
        "#{trainee_section_key.underscore.camelcase}Form".constantize
      end
    end

    def trainee_section_key
      @trainee_section_key ||= request.path.split("/").intersection(trainee_paths).first&.underscore
    end

    def confirm_section_title
      @confirm_section_title ||= {
        training_details: "trainee start date and ID",
        degrees: "degree details",
      }[trainee_section_key.to_sym] || trainee_section_key.gsub(/_/, " ").gsub(/id/, "ID")
    end

    def flash_message_title
      I18n.t(
        "components.confirmation.flash.#{trainee_section_key}",
        default: confirm_section_title.pluralize,
      )
    end

    def toggle_trainee_progress_field
      trainee.progress.public_send("#{trainee_section_key}=", mark_as_completed_params)
      trainee.save!
    end

    def trainee_paths
      @trainee_paths ||= [
        trainee_personal_details_path,
        trainee_contact_details_path,
        trainee_degrees_path,
        trainee_course_details_path,
        trainee_training_details_path,
        trainee_trainee_id_path,
        trainee_start_date_path,
        trainee_schools_path,
      ].map { |path| path.split("/").last }
    end

    def mark_as_completed_params
      mark_as_completed_attributes = params.require(:confirm_detail_form).permit(:mark_as_completed)[:mark_as_completed]

      ActiveModel::Type::Boolean.new.cast(mark_as_completed_attributes)
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
