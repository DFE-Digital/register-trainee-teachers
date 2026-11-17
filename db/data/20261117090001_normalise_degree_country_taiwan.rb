# frozen_string_literal: true

class NormaliseDegreeCountryTaiwan < ActiveRecord::Migration[8.1]
  HESA_LABEL = "Taiwan [Taiwan, Province of China]"
  SHORT_LABEL = "Taiwan"

  # Stored rows predate the `Degree#country` normalisation, so the raw value has to be matched
  # with SQL: a hash condition would be normalised to SHORT_LABEL and find nothing.
  def up
    # rubocop:disable-next Rails/WhereEquals -- hash conditions are normalised by Degree
    Degree.where("country = ?", HESA_LABEL).update_all(country: SHORT_LABEL)
  end

  def down
    # rubocop:disable-next Rails/WhereEquals -- hash conditions are normalised by Degree
    Degree.where("country = ?", SHORT_LABEL).update_all(country: HESA_LABEL)
  end
end
