# frozen_string_literal: true

class NormaliseIqtsCountryTaiwan < ActiveRecord::Migration[8.1]
  HESA_LABEL = "Taiwan [Taiwan, Province of China]"
  SHORT_LABEL = "Taiwan"

  # Stored rows predate the `Trainee#iqts_country` normalisation, so the raw value has to be
  # matched with SQL: a hash condition would be normalised to SHORT_LABEL and find nothing.
  def up
    # rubocop:disable-next Rails/WhereEquals -- hash conditions are normalised by Trainee
    Trainee.where("iqts_country = ?", HESA_LABEL).update_all(iqts_country: SHORT_LABEL)
  end

  def down
    # rubocop:disable-next Rails/WhereEquals -- hash conditions are normalised by Trainee
    Trainee.where("iqts_country = ?", SHORT_LABEL).update_all(iqts_country: HESA_LABEL)
  end
end
