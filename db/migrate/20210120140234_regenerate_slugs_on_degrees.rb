# frozen_string_literal: true

class RegenerateSlugsOnDegrees < ActiveRecord::Migration[6.1]
  def up
    Degree.find_each(&:regenerate_slug)
  end

  def down
    Degree.update_all(slug: nil)
  end
end
