# frozen_string_literal: true

class RemoveTraineeDuplicateDegrees < ActiveRecord::Migration[6.1]
  def up
    Trainee.find_each do |trainee|
      next unless trainee.degrees.many?

      duplicate_ids = find_duplicate_ids(trainee.degrees)
      if duplicate_ids.any?
        trainee.degrees.where(id: duplicate_ids).delete_all
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def find_duplicate_ids(degrees)
    ids = []
    set = Set.new
    degrees.each do |degree|
      digest = degree.values_at(:subject, :institution, :graduation_year, :uk_degree, :non_uk_degree).join
      if set.include?(digest)
        ids << degree.id
      else
        set.add(digest)
      end
    end
    ids
  end
end
