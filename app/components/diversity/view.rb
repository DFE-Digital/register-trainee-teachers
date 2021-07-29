# frozen_string_literal: true

module Diversity
  class View < GovukComponent::Base
    include SanitizeHelper

    def initialize(data_model:, error: false)
      @data_model = data_model
      @error = error
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def diversity_information_rows
      diversity_disclosure_key = data_model.diversity_disclosure || :diversity_not_provided
      rows = [
        {
          key: "Diversity information",
          value: t("components.confirmation.diversity.diversity_disclosure.#{diversity_disclosure_key}"),
          action: govuk_link_to('Change<span class="govuk-visually-hidden"> diversity information</span>'.html_safe,
                                edit_trainee_diversity_disclosure_path(trainee)),
        },
      ]

      if data_model.diversity_disclosed?
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
      return t(:answer_missing) unless data_model.ethnic_group

      value = t("components.confirmation.diversity.ethnic_groups.#{data_model.ethnic_group}")

      if data_model.ethnic_background.present? && data_model.ethnic_background != Diversities::NOT_PROVIDED
        value += " (#{trainee_ethnic_background})"
      end

      value
    end

    def disability_selection
      return t(:answer_missing) unless data_model.disability_disclosure

      t("components.confirmation.diversity.disability_disclosure.#{data_model.disability_disclosure}")
    end

    def selected_disability_options
      return "" if data_model.disabilities.empty?

      selected = tag.p("Disabilities shared:", class: "govuk-body")

      selected + sanitize(tag.ul(class: "govuk-list govuk-list--bullet") do
        render_disabilities
      end)
    end

  private

    attr_accessor :data_model, :error

    def render_disabilities
      data_model.disabilities.each do |disability|
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
      additional_disability = if data_model.is_a?(Trainee)
                                data_model.trainee_disabilities.where(disability_id: disability.id).first.additional_disability
                              else
                                data_model.additional_disability
                              end

      return if additional_disability.blank?

      "(#{additional_disability})"
    end

    def disability_name_for(disability)
      disability.name.downcase
    end

    def trainee_ethnic_background
      data_model.additional_ethnic_background.presence || data_model.ethnic_background
    end
  end
end
