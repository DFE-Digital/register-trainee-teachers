# frozen_string_literal: true

class AddCompositeIndexForDiscrdedAtAndRecordSourceOnTrainees < ActiveRecord::Migration[6.1]
  def change
    add_index :trainees, %i[discarded_at record_source provider_id state], name: "index_trainees_on_discarded_at__record_source__provider__state"
  end
end
