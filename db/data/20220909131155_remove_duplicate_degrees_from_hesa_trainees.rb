# frozen_string_literal: true

class RemoveDuplicateDegreesFromHesaTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.joins(:hesa_student).find_each do |trainee|
      if trainee.hesa_student.degrees&.any? && find_duplicates(trainee.degrees).any?
        Degree.without_auditing do
          trainee.degrees.delete_all
          hesa_degrees = trainee.hesa_student.degrees.map(&:with_indifferent_access)
          Degrees::CreateFromHesa.call(trainee: trainee, hesa_degrees: hesa_degrees)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def find_duplicates(degrees)
    ids = []
    set = Set.new
    degrees.each do |degree|
      digest = degree.values_at(:subject, :institution, :graduation_year, :uk_degree).map(&:to_s).map(&:downcase).join
      if set.include?(digest)
        ids << degree.id
      else
        set.add(digest)
      end
    end
    ids
  end
end
