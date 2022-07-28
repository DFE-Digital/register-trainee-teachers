# frozen_string_literal: true

class RemoveAgeRangeFromIncompatibleCourses < ActiveRecord::Migration[6.1]
  def up
    # These primary education courses have age ranges that are incompatible with Register.
    # The provider will have to enter a compatible age range after selecting the course.
    # Note: Publish doesn't currently validate age ranges.
    Course.where(level: :primary)
          .where("max_age > ?", AgeRange::UPPER_BOUND_PRIMARY_AGE)
          .update_all(min_age: nil, max_age: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
