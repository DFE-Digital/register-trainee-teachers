# frozen_string_literal: true

require "rails_helper"

RSpec.feature "email previews" do
  all_links = (ActionMailer::Preview.all.map do |preview|
    preview.emails.map do |email|
      "/rails/mailers/#{preview.preview_name}/#{email}"
    end
  end).flatten

  shared_examples "navigate to" do |link|
    scenario "navigate to #{link}" do
      visit link

      expect(page.status_code).to eq(200)
    end
  end

  all_links.each do |link|
    include_examples "navigate to", link
  end
end
