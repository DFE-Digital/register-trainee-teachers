# frozen_string_literal: true

module Trainees
  module Placements
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
      before_action { require_feature_flag(:trainee_placement) }

      def show
        page_tracker.save_as_origin!

        if trainee.draft?
          @confirm_detail_form = ConfirmDetailForm.new(mark_as_completed: trainee.progress.placements)
        end

        @confirmation_component = if trainee.placements.empty? && trainee.draft?
                                    CollapsedSection::View.new(
                                      title: t("components.incomplete_section.placement_details_not_provided"),
                                      link_text: t("components.incomplete_section.add_placement_details"),
                                      url: trainee_placements_new_type_path(@trainee),
                                      has_errors: false,
                                    )
                                  else
                                    ::Placements::View.new(data_model: data_model, editable: trainee_editable?)
                                  end
      end

      def update
        if @form.trainee_reset_placements?
          update_placements_for_non_draft_trainee
        else
          super
        end
      end

    private

      def load_missing_data_view
        @missing_data_view = MissingDataView.new(build_form, multiple_records: true)
      end

      def build_form
        PlacementsForm.new(trainee)
      end

      def update_placements_for_non_draft_trainee
        @form.save!

        flash[:success] = "Trainee #{flash_message_title} updated"

        redirect_to(page_tracker.last_origin_page_path || trainee_path(trainee))
      end
    end
  end
end
