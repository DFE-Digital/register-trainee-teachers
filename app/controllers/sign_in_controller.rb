# frozen_string_literal: true

class SignInController < ApplicationController
  skip_before_action :authenticate

  def index
    if FeatureService.enabled?(:dfe_sign_in_fallback)
      redirect_to sign_in_fallback_path
    end
  end
end
