# frozen_string_literal: true

module CsvSandboxBanner
  class View < ApplicationComponent
    def initialize(show_csv_sandbox_banner: Settings.features.show_csv_sandbox_banner)
      @show_csv_sandbox_banner = show_csv_sandbox_banner
    end

    def render?
      show_csv_sandbox_banner
    end

    attr_reader :show_csv_sandbox_banner
  end
end
