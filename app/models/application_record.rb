# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  STRING_CHARACTER_LIMIT = 255

  self.abstract_class = true

  before_validation :apply_character_limits

  private

  def apply_character_limits
    self.class.columns.each do |column|
      if column.type == :string && self[column.name].is_a?(String)
        if self[column.name].length > STRING_CHARACTER_LIMIT
          errors.add(column.name, "is too long (maximum is #{STRING_CHARACTER_LIMIT} characters)")
        end
      end
    end
  end
end
