# frozen_string_literal: true

module Submissions
  class TrnValidator < BaseValidator
    include FundingHelper

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
        *(:schools if trainee.requires_schools?),
        *(:funding if trainee.requires_funding?),
        *(:iqts_country if trainee.requires_iqts_country?)
      ]
    end

    def apply_draft_trainee_sections
      [
        :course_details, :trainee_data,
        :training_details, *(:schools if trainee.requires_schools?),
        :funding
      ]
    end

    def submission_ready
      unless all_sections_complete?
        sections.each do |section|
          next unless sections_validation_status[section] != Progress::STATUSES[:completed]

          if section == :funding && funding_options(trainee) == :funding_inactive
            errors.add(section, I18n.t("components.sections.titles.funding_inactive"))
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
