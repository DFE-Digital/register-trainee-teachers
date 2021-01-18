# frozen_string_literal: true

class NavigationBar::View < GovukComponent::Base
  attr_reader :items

  def initialize(current_user, items:)
    @current_user = current_user
    @items = items
  end

  def user_signed_in?
    @current_user.present?
  end
end
