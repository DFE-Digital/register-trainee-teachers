# frozen_string_literal: true

class AddTraineesSentSlugToDqt < ActiveRecord::Migration[7.0]
  def change
    add_column :trainees, :slug_sent_to_dqt_at, :datetime, null: true
  end
end
