# frozen_string_literal: true

class AddeNewTraineesData < ActiveRecord::Migration[7.2]
  def up
    safety_assured do
      now = Time.current

      execute <<-SQL
        INSERT INTO new_trainees (description, created_at, updated_at)
        VALUES
          ('First trainee', '#{now}', '#{now}'),
          ('Second trainee', '#{now}', '#{now}');
      SQL
    end
  end
end
