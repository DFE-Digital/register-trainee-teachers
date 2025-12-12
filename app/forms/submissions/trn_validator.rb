# frozen_string_literal: true

module Submissions
  class TrnValidator < BaseValidator
    include FundingHelper

    class_attribute :extra_validators, instance_writer: false, default: {}

    class << self
      def missing_data_validator(name, options)
        extra_validators[name] = options
      end
    end

    missing_data_validator :placements, form: "PlacementDetailForm", if: :requires_placements?

    def progress_status(progress_key)
      progress_service(progress_key).status.parameterize(separator: "_").to_sym
    end

    def display_type(section_key)
      progress = progress_status(section_key)
      progress == :completed ? :expanded : :collapsed
    end

    def all_sections_complete?
      @all_sections_complete ||= sections_validation_status.values.all? do |status|
        status == Progress::STATUSES[:completed]
      end
    end

  private

    def sections_validation_status
      @sections_validation_status ||= validator_keys.index_with do |progress_key|
        progress_service(progress_key).status
      end
    end

    def sections
      if trainee.apply_application?
        apply_draft_trainee_sections
      else
        draft_trainee_sections
      end
    end

    def draft_trainee_sections
      [
        :personal_details, :contact_details, :diversity,
        *(:degrees if @trainee.requires_degree?),
        :course_details, :training_details,
        *(:schools if trainee.requires_training_partner?),
        *(:placements if trainee.requires_placements?),
        *(:funding if trainee.requires_funding?),
        *(:iqts_country if trainee.requires_iqts_country?)
      ]
    end

    def apply_draft_trainee_sections
      [
        :course_details,
        :trainee_data,
        :training_details,
        *(:schools if trainee.requires_training_partner?),
        :funding,
        *(:placements if trainee.requires_placements?),
      ]
    end

    def submission_ready
      unless all_sections_complete?
        sections.each do |section|
          next unless sections_validation_status[section] != Progress::STATUSES[:completed]

          if section == :funding && funding_options(trainee) == :funding_inactive
            errors.add(section, I18n.t("components.sections.titles.funding_inactive"))
          elsif section == :placements
            error_message = "#{I18n.t("components.sections.titles.#{section}")} #{I18n.t("components.sections.statuses.#{progress_service(:placements).status}")}"

            errors.add(section, error_message)
          else
            error_message = "#{I18n.t("components.sections.titles.#{section}")} #{I18n.t("components.sections.statuses.#{sections_validation_status[section]}")}"

            errors.add(section, error_message)
          end
        end
      end
    end

    def progress_service(progress_key)
      progress_value = trainee.progress.public_send(progress_key)
      ProgressService.call(validator: validator(progress_key), progress_value: progress_value)
    end
  end
end
