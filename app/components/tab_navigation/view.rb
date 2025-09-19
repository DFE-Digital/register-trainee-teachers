# frozen_string_literal: true

module TabNavigation
  class View < ApplicationComponent
    attr_reader :items

    def initialize(items:, size: :default)
      @items = items&.compact
      @size = size
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
