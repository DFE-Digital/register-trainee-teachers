# frozen_string_literal: true

class RegenerateSlugsOnTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.all.find_each(&:regenerate_slug)
  end

  def down
    Trainee.update_all(slug: nil)
  end
end
