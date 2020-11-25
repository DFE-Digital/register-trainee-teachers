# frozen_string_literal: true

class Header::View < GovukComponent::Base
  attr_accessor :service_name

  include ActiveModel

  def initialize(service_name, current_user = {})
    @service_name = service_name
    @current_user = current_user
  end

  def user_signed_in?
    @current_user.present?
  end
end
