# frozen_string_literal: true

module ExportWithCountButton
  class View < ApplicationComponent
    renders_one :no_record_text

    def initialize(button_text:, count:, count_label:, href:)
      @button_text = button_text
      @count = count
      @count_label = count_label
      @href = href
    end

  private

    attr_reader :button_text, :count, :count_label, :href
  end
end
