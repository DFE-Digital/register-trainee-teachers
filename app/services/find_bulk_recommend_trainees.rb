# frozen_string_literal: true

class FindBulkRecommendTrainees
  include ServicePattern

  def call
    itt_end_date_range = [(Time.zone.today - 6.months).iso8601, (Time.zone.today + 6.months).iso8601]

    itt_end_date_within_six_months = <<~SQL
      '#{itt_end_date_range}'::daterange @> trainees.itt_end_date OR
      trainees.itt_end_date IS NULL
    SQL

    Trainee.trn_received.where(itt_end_date_within_six_months)
  end
end
