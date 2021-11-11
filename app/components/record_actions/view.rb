# frozen_string_literal: true

module RecordActions
  class View < GovukComponent::Base
    include ApplicationHelper

    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end

    def display_actions?
      trainee.submitted_for_trn? || trainee.trn_received? || trainee.deferred?
    end

    def can_recommend_for_award?
      trainee.trn_received?
    end

    def action_links
      links = [withdraw_link]

      if trainee.deferred?
        links.prepend(reinstate_link)
      else
        links.prepend(defer_link)
      end

      if delete_allowed?
        links.prepend(delete_link)
      end

      links.join(" or ").html_safe
    end

  private

    def button_text
      if trainee.early_years_route?
        t("views.trainees.edit.recommend_for_eyts")
      else
        t("views.trainees.edit.recommend_for_award")
      end
    end

    def delete_link
      govuk_link_to(t("views.trainees.edit.delete"), trainee_confirm_delete_path(trainee), class: "delete")
    end

    def defer_link
      govuk_link_to(t("views.trainees.edit.defer"), trainee_deferral_path(trainee), class: "defer")
    end

    def withdraw_link
      govuk_link_to(t("views.trainees.edit.withdraw"), trainee_withdrawal_path(trainee), class: "withdraw")
    end

    def reinstate_link
      govuk_link_to(t("views.trainees.edit.reinstate"), trainee_reinstatement_path(trainee), class: "reinstate")
    end

    def delete_allowed?
      course_starting_in_the_future? || course_started_but_trainee_has_not_specified_start_date?
    end

    def course_starting_in_the_future?
      trainee.course_start_date && trainee.course_start_date > Time.zone.now
    end

    def course_started_but_trainee_has_not_specified_start_date?
      !course_starting_in_the_future? && trainee.commencement_date.blank?
    end
  end
end
