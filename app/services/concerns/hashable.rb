# frozen_string_literal: true

module Hashable
  # Search for a specific key in a Hash and return its value
  #
  def deep_dig(obj, key)
    stack   = [obj]
    visited = Set.new

    until stack.empty?
      current = stack.pop

      next if visited.include?(current)

      visited.add(current)

      if current.is_a?(Hash)
        return current[key] if current.key?(key)

        stack.push(*current.values)
      elsif current.is_a?(Array)
        stack.push(*current)
      end
    end
  end
end
