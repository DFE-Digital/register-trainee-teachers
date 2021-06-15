# frozen_string_literal: true

class RequestAnAccountController < ApplicationController
  skip_before_action :authenticate

  def index; end
end
