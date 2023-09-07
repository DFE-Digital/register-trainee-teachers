# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate

  def accessibility
    render(:accessibility)
  end

  def privacy_notice
    render(:privacy_notice)
  end

  def dttp_replaced
    render(:dttp_replaced)
  end

  def data_sharing_agreement
    render(:data_sharing_agreement)
  end
end
