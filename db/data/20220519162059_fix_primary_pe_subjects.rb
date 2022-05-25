# frozen_string_literal: true

class FixPrimaryPeSubjects < ActiveRecord::Migration[6.1]
  def up
    trainee_ids = [
      100790,
      90738,
      90740,
      90747,
      91105,
      102185,
      106488,
      106494,
      106564,
      106573,
      106584,
      106539,
      106590,
      106595,
      106572,
      106568,
      106658,
      106650,
      106676,
      106695,
      106697,
      106714,
      106735,
      106778,
      106781,
      106774,
      109263,
      109265,
      85174,
      109624,
    ]

    primary_allocation_subject_id = AllocationSubject.find_by(name: "Primary").id

    Trainee.where(id: trainee_ids).each do |trainee|
      trainee.without_auditing do
        trainee.update(
          course_subject_one: "primary teaching",
          course_subject_two: "sport and exercise sciences",
          course_allocation_subject_id: primary_allocation_subject_id,
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
