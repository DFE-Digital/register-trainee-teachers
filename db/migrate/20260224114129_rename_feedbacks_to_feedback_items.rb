# frozen_string_literal: true

class RenameFeedbacksToFeedbackItems < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      rename_table :feedbacks, :feedback_items
    end
  end
end
