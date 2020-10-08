require_relative "20200901113117_add_previous_education.rb"

class RevertPreviousEducation < ActiveRecord::Migration[6.0]
  def change
    revert AddPreviousEducation
  end
end
