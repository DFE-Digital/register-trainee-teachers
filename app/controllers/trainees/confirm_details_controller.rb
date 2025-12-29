# frozen_string_literal: true

module Trainees
  class ConfirmDetailsController < BaseController
    before_action :load_form, :load_missing_data_view

    helper_method :trainee_section_key
    helper_method :confirm_section_title

    SCHOOLS_KEY = "schools"
    FUNDING_KEY = "funding"

    def show
      page_tracker.save_as_origin!

      if trainee.draft?
        @confirm_detail_form = ConfirmDetailForm.new(mark_as_completed: trainee.progress.public_send(trainee_progress_key))
      end

      @confirmation_component = view_component.new(data_model: data_model, editable: trainee_editable?)
    end

    def update
      if @form.valid?
        trainee.draft? ? toggle_trainee_progress_field : @form.save!

        flash[:success] = "Trainee #{flash_message_title} updated"

        redirect_to(page_tracker.last_origin_page_path || trainee_path(trainee))
      else
        @confirmation_component = view_component.new(data_model: data_model, has_errors: true, editable: trainee_editable?)

        render(:show)
      end
    end

  private

    def data_model
      trainee.draft? ? trainee : @form
    end

    def view_component
      "::#{trainee_section_key.underscore.camelcase}::View".constantize
    end

    def form_klass
      case trainee_section_key
      when SCHOOLS_KEY
        Schools::FormValidator
      when FUNDING_KEY
        ::Funding::FormValidator
      else
        "#{trainee_section_key.underscore.camelcase}Form".constantize
      end
    end

    def trainee_progress_key
      if trainee_section_key == "publish_course_details"
        "course_details"
      else
        trainee_section_key
      end
    end

    # Returns the route that the confirm path is nested under for each confirm path
    # eg /trainees/<slug>/funding/confirm returns 'funding'
    def trainee_section_key
      @trainee_section_key ||= request.path.split("/")[-2]&.underscore
    end

    def confirm_section_title
      @confirm_section_title ||= {
        training_details: "trainee ID",
        degrees: "degree details",
        placements: "placement details",
        funding: "funding details",
        course_details: "trainee's course details",
        publish_course_details: "trainee's course details",
        trainee_start_status: "start date",
        iqts_country: "international training details",
        schools: "training partners",
      }[trainee_section_key.to_sym] || trainee_section_key.gsub("_", " ").gsub("id", "ID")
    end

    def flash_message_title
      I18n.t("components.confirmation.flash.#{trainee_section_key}", default: confirm_section_title)
    end

    def toggle_trainee_progress_field
      trainee.progress.public_send("#{trainee_progress_key}=", mark_as_completed_params)
      trainee.save!
    end

    def mark_as_completed_params
      mark_as_completed_attributes = params.expect(confirm_detail_form: [:mark_as_completed])[:mark_as_completed]

      ActiveModel::Type::Boolean.new.cast(mark_as_completed_attributes)
    end

    def load_form
      @form = build_form
    end

    def load_missing_data_view
      @missing_data_view = MissingDataView.new(build_form)
    end

    def build_form
      trainee_section_key == SCHOOLS_KEY ? form_klass.new(trainee, non_search_validation: true) : form_klass.new(trainee)
    end
  end
end
