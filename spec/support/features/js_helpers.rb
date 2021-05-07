# frozen_string_literal: true

module Features
  module JsHelpers
    def js_true?
      RSpec.current_example.metadata[:js]
    end

    def click(node)
      if js_true?
        node.trigger(:click)
      else
        node.click
      end
    end
  end
end
