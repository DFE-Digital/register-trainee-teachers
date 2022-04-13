# frozen_string_literal: true

class AddHecosCodeToSubjectSpecialism < ActiveRecord::Migration[6.1]
  def change
    add_column :subject_specialisms, :hecos_code, :string
  end
end
