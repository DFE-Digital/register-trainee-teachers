# frozen_string_literal: true

namespace :trainee do
  desc "fix the incorrect end academic cycle for recently awarded and withdrawn trainees"
  task fix_academic_cycles: :environment do
    # We have excluded HESA trainees because they are not awarded or withdrawn currently in Register
    awarded_trainees = Trainee.awarded.where(hesa_id: nil).where("updated_at > ?", "01/06/2022".to_date)

    withdrawn_trainees = Trainee.withdrawn.where(hesa_id: nil).where("updated_at > ?", "01/06/2022".to_date)

    (awarded_trainees + withdrawn_trainees).each do |trainee|
      Trainees::SetAcademicCyclesJob.perform_later(trainee)
    end
  end
end
