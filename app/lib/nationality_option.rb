# frozen_string_literal: true

class NationalityOption
  attr_reader :id, :name, :description

  def initialize(id:, name:, description: nil)
    @id = id
    @name = name
    @description = description
  end
end
