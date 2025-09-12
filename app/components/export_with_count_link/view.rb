# frozen_string_literal: true

module ExportWithCountLink
  class View < ApplicationComponent
    renders_one :no_record_text

    def initialize(link_text:, count:, count_label:, href:)
      @link_text = link_text
      @count = count
      @count_label = count_label
      @href = href
    end

    def link_label
      "#{link_text} (#{count} #{count_label.pluralize(count)})"
    end

  private

    attr_reader :link_text, :count, :count_label, :href
  end
end
