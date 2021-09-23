# frozen_string_literal: true

class ResetUpdateShaForFunding < ActiveRecord::Migration[6.1]
  # We started collecting funding details for trainees before we were ready to
  # send this information to DTTP.
  #
  # Here we find all trainees who's funding details were updated before the
  # integration was switched on and re-set their dttp_update_sha. This means
  # they will be updated in DTTP overnight during the QueueTraineeUpdatesJob.
  def up
    fields = %w[applying_for_bursary bursary_tier training_initiative]

    funding_changed = fields.map { |field| "(audited_changes->'#{field}' IS NOT NULL)" }
                            .join(" OR ")

    trainee_ids = Audited::Audit.where(auditable_type: "Trainee", action: "update", created_at: Date.new..28.days.ago)
                                .where(funding_changed)
                                .pluck(:auditable_id).uniq

    Trainee.where(id: trainee_ids).where.not(state: "draft").find_each do |trainee|
      Dttp::UpdateTraineeToDttpJob.perform_later(trainee)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
