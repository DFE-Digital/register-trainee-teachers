# frozen_string_literal: true

class NewsController < ApplicationController
  skip_before_action :authenticate

  def index
    @news_articles = NewsArticle.all
  end

  def show
    @news_article = NewsArticle.find_by(slug: params[:id])
  end
end
