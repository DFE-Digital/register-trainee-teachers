# frozen_string_literal: true

class FindBulkRecommendTrainees
  include ServicePattern

  # rubocop:disable Style/TrailingCommaInArguments
  def call
    itt_end_date_range = [(Time.zone.today - 6.months).iso8601, (Time.zone.today + 6.months).iso8601]

    Trainee
      .where(state: :trn_received)
      .where(
        <<~SQL
          '#{itt_end_date_range}'::daterange @> trainees.itt_end_date OR
          trainees.itt_end_date IS NULL
        SQL
      ).order(last_name: :asc)
  end
  # rubocop:enable Style/TrailingCommaInArguments
end
