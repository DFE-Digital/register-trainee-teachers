# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate

  def accessibility; end

  def privacy_notice; end

  def data_sharing_agreement; end

  def dttp_replaced
    render(:dttp_replaced, layout: "application")
  end
end
