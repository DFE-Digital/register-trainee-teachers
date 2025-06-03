# frozen_string_literal: true

# == Schema Information
#
# Table name: news_articles
#
#  id           :bigint           not null, primary key
#  content      :text             not null
#  published    :boolean          default(FALSE), not null
#  published_at :datetime
#  slug         :string           not null
#  summary      :string           not null
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_news_articles_on_slug  (slug) UNIQUE
#
class NewsArticle < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :summary, presence: true

  def date
    published_at
  end
end
