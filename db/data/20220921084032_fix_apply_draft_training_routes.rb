# frozen_string_literal: true

class FixApplyDraftTrainingRoutes < ActiveRecord::Migration[6.1]
  def up
    Trainee.draft.where(record_source: RecordSources::APPLY).where.not(course_uuid: nil).find_each do |trainee|
      if trainee.published_course && trainee.training_route != trainee.published_course.route
        trainee.without_auditing do
          trainee.progress.funding = false
          trainee.assign_attributes(training_route: trainee.published_course.route,
                                    applying_for_bursary: nil,
                                    applying_for_scholarship: nil,
                                    applying_for_grant: nil,
                                    bursary_tier: nil)

          if trainee.published_course.route == "provider_led_postgrad"
            trainee.lead_school_id = nil
          end

          trainee.save!
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
