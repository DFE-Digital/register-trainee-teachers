# frozen_string_literal: true

module SystemAdmin
  class RelevantDegreeSubjectsController < ApplicationController
    def index
      @relevant_degree_subjects = RelevantDegreeSubject
        .includes(:academic_cycle, :allocation_subject)
        .order_by_academic_year_and_subject
        .page(params[:page] || 1)
    end
  end
end
