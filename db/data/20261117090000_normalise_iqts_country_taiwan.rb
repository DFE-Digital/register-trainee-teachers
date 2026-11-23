# frozen_string_literal: true

class NormaliseIqtsCountryTaiwan < ActiveRecord::Migration[8.1]
  HESA_LABEL = "Taiwan [Taiwan, Province of China]"
  SHORT_LABEL = "Taiwan"

  def up
    # rubocop:disable-next Rails/WhereEquals
    Trainee.where("iqts_country = ?", HESA_LABEL).update_all(iqts_country: SHORT_LABEL)
  end

  def down
    # rubocop:disable-next Rails/WhereEquals
    Trainee.where("iqts_country = ?", SHORT_LABEL).update_all(iqts_country: HESA_LABEL)
  end
end
