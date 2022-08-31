# frozen_string_literal: true

class GuidanceController < ApplicationController
  skip_before_action :authenticate

  def show; end

  def about_register_trainee_teachers
    render(template: "guidance/about_register_trainee_teachers.md", layout: "guidance_markdown")
  end

  def dates_and_deadlines
    render(:dates_and_deadlines)
  end
end
