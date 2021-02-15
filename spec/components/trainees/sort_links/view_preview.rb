# frozen_string_literal: true

require "govuk/components"

module Trainees
  module SortLinks
    class ViewPreview < ViewComponent::Preview
      def default_view
        render Trainees::SortLinks::View.new
      end
    end
  end
end
