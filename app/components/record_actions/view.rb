# frozen_string_literal: true

module RecordActions
  class View < ViewComponent::Base
    include ApplicationHelper
    include SummaryHelper

    attr_reader :trainee

    def initialize(trainee, has_missing_fields: false)
      @trainee = trainee
      @has_missing_fields = has_missing_fields
    end

    def display_actions?
      trainee.submitted_for_trn? || trainee.trn_received? || trainee.deferred?
    end

    def can_recommend_for_award?
      trainee.trn_received? && !has_missing_fields && !course_starting_in_the_future?
    end

    def action_links_sentence
      links = action_links.join(" or ")
      links.concat(this_trainee_text) unless delete_allowed_but_not_withdraw?
      links.html_safe
    end

    def inset_text
      if has_missing_fields
        t("views.trainees.edit.status_summary.missing_fields")
      elsif course_starting_in_the_future?
        t("views.trainees.edit.status_summary.itt_not_started", itt_start_date: date_for_summary_view(trainee.itt_start_date))
      else
        t("views.trainees.edit.status_summary.#{trainee.state}")
      end
    end

    def button_text
      if trainee.early_years_route?
        t("views.trainees.edit.recommend_for_eyts")
      else
        t("views.trainees.edit.recommend_for_award")
      end
    end

  private

    attr_reader :has_missing_fields

    def action_links
      links = []

      if delete_allowed?
        links.append(:delete_link)
      end

      if trainee.deferred?
        links.append(:reinstate_link)
      else
        links.append(:defer_link)
      end

      if withdraw_allowed?
        links.append(:withdraw_link)
      end

      links.map.with_index { |link_method, i| send(link_method, i.zero?) }
    end

    def delete_link(capitalise)
      text = maybe_capitalise(t("views.trainees.edit.delete"), capitalise)
      govuk_link_to(text, trainee_start_date_verification_path(trainee, context: :delete), class: "delete")
    end

    def defer_link(capitalise)
      text = maybe_capitalise(t("views.trainees.edit.defer"), capitalise)
      text += this_trainee_text if delete_allowed_but_not_withdraw?
      path = (if trainee.hesa_record?
                trainee_interstitials_hesa_deferrals_path(trainee)
              else
                trainee_deferral_path(trainee)
              end)
      govuk_link_to(text, path, class: "defer")
    end

    def reinstate_link(capitalise)
      text = maybe_capitalise(t("views.trainees.edit.reinstate"), capitalise)
      text += this_trainee_text if delete_allowed_but_not_withdraw?
      path = (if trainee.hesa_record?
                trainee_interstitials_hesa_reinstatements_path(trainee)
              else
                trainee_reinstatement_path(trainee)
              end)
      govuk_link_to(text, path, class: "reinstate")
    end

    def withdraw_link(capitalise)
      text = maybe_capitalise(t("views.trainees.edit.withdraw"), capitalise)
      govuk_link_to(text, relevant_redirect_path, class: "withdraw")
    end

    def this_trainee_text
      " #{t('views.trainees.edit.this_trainee')}"
    end

    def delete_allowed?
      course_starting_in_the_future? || course_started_but_no_specified_start_date?
    end

    def withdraw_allowed?
      !course_starting_in_the_future? && !trainee.itt_not_yet_started?
    end

    def delete_allowed_but_not_withdraw?
      delete_allowed? && !withdraw_allowed?
    end

    def course_starting_in_the_future?
      trainee.starts_course_in_the_future?
    end

    def course_started_but_no_specified_start_date?
      !course_starting_in_the_future? && trainee.trainee_start_date.blank?
    end

    def relevant_redirect_path
      if trainee.trainee_start_date.present?
        trainee_withdrawal_start_path(trainee)
      else
        trainee_start_date_verification_path(trainee, context: :withdraw)
      end
    end

    def maybe_capitalise(text, condition)
      text.capitalize! if condition
      text
    end
  end
end
