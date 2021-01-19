# frozen_string_literal: true

class NavigationBar::View < GovukComponent::Base
  attr_reader :items

  def initialize(items:)
    @items = items
  end

  def item_link(item)
    link_params = { class: "moj-primary-navigation__link" }
    link_params.merge!(aria: { current: "page" }) if show_current_link?(item)
    govuk_link_to(item[:name], item[:url], link_params)
  end

private

  def show_current_link?(item)
    item.fetch(:current, false) || current_page?(item.fetch(:url))
  end
end
