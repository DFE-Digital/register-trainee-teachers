# frozen_string_literal: true

class CookiePreferencesController < ApplicationController
  skip_before_action :authenticate

  def show
    @cookie_preferences_form = CookiePreferencesForm.new(cookies)
  end

  def update
    @cookie_preferences_form = CookiePreferencesForm.new(cookies, cookie_preferences_params)

    if @cookie_preferences_form.save
      redirect_back_or_to(root_path, flash: { success: t("cookies.preference_updated") })
    else
      render(:show)
    end
  end

private

  def cookie_preferences_params
    params.require(:cookie_preferences_form).permit(:consent)
  end
end
