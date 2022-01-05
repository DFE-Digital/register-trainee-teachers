# frozen_string_literal: true

class NavigationBar::View < GovukComponent::Base
  attr_reader :items, :current_path, :current_user

  def initialize(items:, current_path:, current_user: {})
    @items = items
    @current_path = current_path
    @current_user = current_user
  end

  def item_link(item)
    link_params = { class: link_class }
    link_params.merge!(aria: { current: "page" }) if show_current_link?(item)
    govuk_link_to(item[:name], item[:url], link_params)
  end

  def organisation_link
    govuk_link_to(organisation.name, organisation_contexts_path, class: link_class )
  end

  def user_signed_in?
    current_user.present?
  end

  def show_organisation_link?
    user_signed_in? &&
      current_user.has_multiple_organisations? &&
      current_user.organisation.present?
  end

  def organisation
    current_user.organisation
  end

  def link_class
    "moj-primary-navigation__link"
  end

private

  def show_current_link?(item)
    item.fetch(:current, false) || current_path == item.fetch(:url)
  end
end
