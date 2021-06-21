# frozen_string_literal: true

require_relative "20200901113117_add_previous_education"

class RevertPreviousEducation < ActiveRecord::Migration[6.0]
  def change
    revert AddPreviousEducation
  end
end
