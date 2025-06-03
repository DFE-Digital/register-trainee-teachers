# frozen_string_literal: true

class PopulateNewsArticles < ActiveRecord::Migration[7.2]
  def change
    ServiceUpdate.all.each do |service_update|
      NewsArticle.create!(
        title: service_update.title,
        slug: service_update.slug,
        summary: service_update.summary,
        content: service_update.content,
        published: true,
        published_at: service_update.date,
      )
    end
  end
end
