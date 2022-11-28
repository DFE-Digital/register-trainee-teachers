# frozen_string_literal: true

class EnablePgTrgm < ActiveRecord::Migration[6.1]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
  end

  def down
    execute "DROP EXTENSION IF EXISTS pg_trgm;"
  end
end
