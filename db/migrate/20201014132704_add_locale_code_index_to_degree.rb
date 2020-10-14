class AddLocaleCodeIndexToDegree < ActiveRecord::Migration[6.0]
  def change
    add_index :degrees, :locale_code
  end
end
