# frozen_string_literal: true

module Trainees
  module Degrees
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
      before_action :authorize_trainee

      def show
        page_tracker.save_as_origin!

        if trainee.draft?
          @confirm_detail_form = ConfirmDetailForm.new(mark_as_completed: trainee.progress.degrees)
        end

        data_model = trainee.draft? ? trainee : degrees_form

        @confirmation_component = if trainee.degrees.empty?
                                    CollapsedSection::View.new(title: t("components.incomplete_section.degree_details_not_provided"), link_text: t("components.incomplete_section.add_degree_details"), url: trainee_degrees_new_type_path(@trainee), error: false)
                                  else
                                    Trainees::Confirmation::Degrees::View.new(data_model: data_model)
                                  end
      end

    private

      def degrees_form
        @degrees_form ||= DegreesForm.new(trainee)
      end
    end
  end
end
