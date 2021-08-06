# frozen_string_literal: true

class UpdateDttpIds < ActiveRecord::Migration[6.1]
  def up
    trainee_one = Trainee.from_param("XaGziQXghtBfH6VUhgRrSLMa")
    if trainee_one.present?
      ActiveRecord::Base.connection.execute(
        "UPDATE trainees SET dttp_id = '102f6f17-bb03-eb11-a812-000d3ab5d7e6', placement_assignment_dttp_id = '9f78a844-5df2-eb11-94ee-000d3ab23888' WHERE id = #{trainee_one.id}",
      )
    end

    trainee_two = Trainee.from_param("AX7MmPYKKt9R1WLRZ7XXsioe")
    if trainee_two.present?
      ActiveRecord::Base.connection.execute(
        "UPDATE trainees SET dttp_id = '162f6f17-bb03-eb11-a812-000d3ab5d7e6', placement_assignment_dttp_id = '1c8d70a6-5df2-eb11-94ee-000d3ab2366d' WHERE id = #{trainee_two.id}",
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
