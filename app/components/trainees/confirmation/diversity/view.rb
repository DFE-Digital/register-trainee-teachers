# frozen_string_literal: true

module Trainees
  module Confirmation
    module Diversity
      class View < GovukComponent::Base
        include SanitizeHelper

        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
        end

        def diversity_information_rows
          rows = [
            {
              key: "Diversity information",
              value: I18n.t("components.confirmation.diversity.diversity_disclosure.#{trainee.diversity_disclosure}"),
              action: govuk_link_to('Change<span class="govuk-visually-hidden"> diversity information</span>'.html_safe,
                                    edit_trainee_diversity_disclosure_path(trainee)),
            },
          ]

          if trainee.diversity_disclosure == "diversity_disclosed"
            rows << {
              key: "Ethnicity",
              value: ethnic_group_content,
              action: govuk_link_to('Change<span class="govuk-visually-hidden"> ethnicity</span>'.html_safe,
                                    edit_trainee_diversity_ethnic_group_path(trainee)),
            }

            rows << {
              key: "Disability",
              value: tag.p(disability_selection, class: "govuk-body") + selected_disability_options,
              action: govuk_link_to('Change<span class="govuk-visually-hidden"> disability</span>'.html_safe,
                                    edit_trainee_diversity_disability_disclosure_path(trainee)),
            }
          end
          rows
        end

        def ethnic_group_content
          value = I18n.t("components.confirmation.diversity.ethnic_groups.#{trainee.ethnic_group}")

          if trainee.ethnic_background.present? && trainee.ethnic_background != Diversities::NOT_PROVIDED
            value += " (#{trainee_ethnic_background})"
          end
          value
        end

        def disability_selection
          if trainee.disabled?
            "They shared that they’re disabled"
          elsif trainee.no_disability?
            "They shared that they’re not disabled"
          else
            "Not provided"
          end
        end

        def selected_disability_options
          return "" if trainee.disabilities.blank?

          selected = tag.p("Disabilities shared:", class: "govuk-body")

          selected + sanitize(tag.ul(class: "govuk-list govuk-list--bullet") do
            render_disabilities
          end)
        end

      private

        def render_disabilities
          trainee.disabilities.each do |disability|
            if disability.name == Diversities::OTHER
              render_additional_disability(disability)
            else
              concat(tag.li(disability_name_for(disability)))
            end
          end
        end

        def render_additional_disability(disability)
          concat(tag.li("#{disability_name_for(disability)} #{additional_disability_for(disability)}"))
        end

        def additional_disability_for(disability)
          additional_disability = trainee.trainee_disabilities.where(disability_id: disability.id).first.additional_disability
          return if additional_disability.blank?

          "(#{additional_disability})"
        end

        def disability_name_for(disability)
          disability.name.downcase
        end

        def trainee_ethnic_background
          trainee.additional_ethnic_background.presence || trainee.ethnic_background
        end
      end
    end
  end
end
