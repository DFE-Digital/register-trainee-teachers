# frozen_string_literal: true

require "progress_bar"

namespace :trainee do
  desc "Recalculate academic cycles for all trainees"
  task recalculate_academic_cycles: :environment do
    trainees = Trainee.where.not(start_academic_cycle_id: nil).and(Trainee.where.not(end_academic_cycle_id: nil))
    bar = ProgressBar.create(total: trainees.count)
    trainees.find_each do |trainee|
      Trainees::SetAcademicCycles.call(trainee:).save!
      bar.increment
    end
  end
end
