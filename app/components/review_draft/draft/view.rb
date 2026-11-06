# frozen_string_literal: true

module ReviewDraft
  module Draft
    class View < ApplicationComponent
      include TraineeHelper
      include TaskListHelper
      include FundingHelper

      attr_reader :trainee

      def initialize(trainee:, funding_prerequisites: [], course_prerequisites: [])
        @trainee = trainee
        @funding_prerequisites = Array(funding_prerequisites).map(&:to_sym)
        @course_prerequisites = Array(course_prerequisites).map(&:to_sym)
      end

      # The Level 5 declaration task, with an error when course details need it first.
      def level_five_declaration_row
        row = row_helper(trainee, :level_five_declaration_details)
        return row unless @course_prerequisites.include?(:level_five_declaration)

        row.merge(error_text: t("views.forms.course_prerequisites.level_five_declaration.task"))
      end

      # The course details task, with a hint when the Level 5 declaration changed after it was added.
      def course_details_row(task)
        row = row_helper(trainee, task)
        return row unless course_details_recheck?(trainee)

        row.merge(hint_text: t("views.forms.funding.recheck.task_course_details"))
      end

      # The task row, with an error when funding needs it completed first.
      def task_row(task, prerequisite: nil)
        row = row_helper(trainee, task)
        return row unless prerequisite && @funding_prerequisites.include?(prerequisite)

        row.merge(error_text: t("views.forms.funding.prerequisites.#{prerequisite}.task"))
      end

      # The funding task, with a hint when the course details, degree or employing
      # school changed after the funding was added, or the funding was removed.
      def funding_row
        row = row_helper(trainee, funding_options(trainee))
        return row if row[:active] == false

        if (changed = funding_recheck_changed(trainee))
          row.merge(hint_text: t("views.forms.funding.recheck.task", changed: changed.upcase_first))
        elsif (removed = funding_removed_reason(trainee))
          row.merge(hint_text: t("views.forms.funding.recheck.task_removed.#{removed}"))
        else
          row
        end
      end

      # The training partner and employing school (or employing school) task, with a
      # hint when the course details changed after it was completed.
      def schools_row(task, prerequisite: nil)
        row = task_row(task, prerequisite:)
        return row unless schools_recheck?(trainee)

        row.merge(hint_text: t("views.forms.funding.recheck.task_schools"))
      end
    end
  end
end
