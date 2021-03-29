# frozen_string_literal: true

module RuboCop
  module Cop
    module Register
      class RegisterFormWith < Base
        def on_send(node)
          return unless node.method_name == :form_with

          add_offense(node, message: "Use the register_form_with helper method instead of inbuilt Rails form_with method")
        end
      end
    end
  end
end
