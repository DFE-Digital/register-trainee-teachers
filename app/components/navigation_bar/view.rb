# frozen_string_literal: true

class NavigationBar::View < ViewComponent::Base
  attr_reader :service_name, :items, :current_path, :current_user

  def initialize(items:, current_path:, current_user: {}, render_without_current_user: false)
    @service_name = I18n.t("service_name")
    @items = items.compact
    @current_path = current_path
    @current_user = current_user
    @render_without_current_user = render_without_current_user
  end

  def render?
    current_user.present? || @render_without_current_user
  end

  def item_link(item)
    link_params = { class: "govuk-service-navigation__link" }
    link_params.merge!(aria: { current: "page" }) if show_current_link?(item)

    govuk_link_to(item[:name], item[:url], **link_params)
  end

  def list_item_classes(item)
    [
      "govuk-service-navigation__item #{' govuk-service-navigation__item--active' if show_current_link?(item)}",
      ("app-service-navigation__align_right" if item[:align_right]),
    ].compact.join(" ")
  end

private

  def show_current_link?(item)
    item.fetch(:current, false) || current_path == item.fetch(:url)
  end

  def navigation_wrapper_classes
    @items.many? ? "app-service-navigation__wrapper" : ""
  end
end
