# frozen_string_literal: true

module SystemAdmin
  module Schools
    class ConfirmDetailsController < ApplicationController
      def show
        school_form
      end

      def update
        if school_form.save
          redirect_to school_path(school)
        end
      end

      private

      def school_form
        @school_form = SchoolForm.new(school)
      end

      def school
        @school ||= policy_scope(School).find(params[:school_id])
      end
    end
  end
end
