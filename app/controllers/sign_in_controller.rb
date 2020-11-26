# frozen_string_literal: true

class SignInController < ApplicationController
  skip_before_action :authenticate
end
