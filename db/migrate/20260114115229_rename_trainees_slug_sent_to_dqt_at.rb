class RenameTraineesSlugSentToDqtAt < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      rename_column :trainees, :slug_sent_to_dqt_at, :slug_sent_to_trs_at
    end
  end
end
