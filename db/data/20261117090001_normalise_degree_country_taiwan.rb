# frozen_string_literal: true

class NormaliseDegreeCountryTaiwan < ActiveRecord::Migration[8.1]
  HESA_LABEL = "Taiwan [Taiwan, Province of China]"
  SHORT_LABEL = "Taiwan"

  def up
    # rubocop:disable-next Rails/WhereEquals
    Degree.where("country = ?", HESA_LABEL).update_all(country: SHORT_LABEL)
  end

  def down
    # rubocop:disable-next Rails/WhereEquals
    Degree.where("country = ?", SHORT_LABEL).update_all(country: HESA_LABEL)
  end
end
