# frozen_string_literal: true

module TabNavigation
  class View < ApplicationComponent
    attr_reader :items, :aria_label

    def initialize(items:, size: :default, aria_label: "Sub navigation")
      @items = items&.compact
      @size = size
      @aria_label = aria_label
    end

  private

    attr_reader :size

    def list_item_class
      case size
      when :default
        "app-tab-navigation__item"
      when :compact
        "app-tab-navigation__item-compact"
      end
    end
  end
end
