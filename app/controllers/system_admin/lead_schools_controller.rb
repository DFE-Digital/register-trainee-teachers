# frozen_string_literal: true

module SystemAdmin
  class LeadSchoolsController < ApplicationController
    def index
      @lead_schools = policy_scope(School, policy_scope_class: LeadSchoolPolicy::Scope).order_by_name.page(params[:page] || 1)
    end

    def show
      @lead_school = authorize(School.lead_only.find(params[:id]), policy_class: LeadSchoolPolicy)
    end
  end
end
