# frozen_string_literal: true

class BackfillManchesterTraineeDegreesHesa < ActiveRecord::Migration[6.1]
  def up
    return unless Rails.env.production?

    ::Hesa::BackFilling.call(
      trns: %w[
        2180790
        2181781
        2174125
        2172241
      ],
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
