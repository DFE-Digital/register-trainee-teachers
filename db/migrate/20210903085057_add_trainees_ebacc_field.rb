# rubocop:disable Rails/ThreeStateBooleanColumn
# frozen_string_literal: true

class AddTraineesEbaccField < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :ebacc, :boolean, default: false
  end
end
# rubocop:enable Rails/ThreeStateBooleanColumn
