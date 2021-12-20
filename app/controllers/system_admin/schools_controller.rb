# frozen_string_literal: true

module SystemAdmin
  class SchoolsController < ApplicationController
    def index
      @schools = policy_scope(School).order_by_name.page(params[:page] || 1)
    end
  end
end
