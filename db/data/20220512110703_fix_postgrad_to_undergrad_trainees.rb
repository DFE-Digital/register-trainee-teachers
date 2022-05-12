# frozen_string_literal: true

class FixPostgradToUndergradTrainees < ActiveRecord::Migration[6.1]
  def up
    trainees = Trainee.where(training_route: "provider_led_postgrad").where.not(hesa_updated_at: nil)
    trainees.each do |trainee|
      next unless Hesa::CodeSets::IttQualificationAims::UNDERGRAD_AIMS.include?(trainee.hesa_metadatum.itt_qualification_aim)

      trainee.without_auditing do
        trainee.update(training_route: "provider_led_undergrad")
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
