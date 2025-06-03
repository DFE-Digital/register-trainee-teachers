class CreateNewsArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :news_articles do |t|
      t.timestamps
      t.string :title, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :summary, null: false
      t.text :content, null: false
      t.boolean :published, default: false, null: false
      t.datetime :published_at, null: true
    end
  end
end
