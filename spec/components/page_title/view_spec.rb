# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageTitle::View do
  before do
    allow(I18n).to receive(:t).with("service_name").and_return("Cool Service")
  end

  it "constructs a page title with empty params" do
    component = PageTitle::View.new
    page_title = component.build_page_title
    expect(page_title).to eq("Cool Service - GOV.UK")
  end

  context "title as text" do
    it "constructs a page title using the provided value" do
      component = PageTitle::View.new(text: "Some title")
      page_title = component.build_page_title
      expect(page_title).to eq("Some title - Cool Service - GOV.UK")
    end

    context "when has_errors is true" do
      it "constructs a page title value with an error" do
        component = PageTitle::View.new(text: "Some title", has_errors: true)
        page_title = component.build_page_title
        expect(page_title).to eq("Error: Some title - Cool Service - GOV.UK")
      end
    end
  end

  context "title as i18n key" do
    before do
      allow(I18n).to receive(:t).with("components.page_titles.trainee.new").and_return("New Trainee")
    end

    it "constructs a page title value" do
      component = PageTitle::View.new(i18n_key: "trainee.new")
      page_title = component.build_page_title
      expect(page_title).to eq("New Trainee - Cool Service - GOV.UK")
    end

    context "when has_errors is true" do
      it "constructs a page title value with an error" do
        component = PageTitle::View.new(i18n_key: "trainee.new", has_errors: true)
        page_title = component.build_page_title
        expect(page_title).to eq("Error: New Trainee - Cool Service - GOV.UK")
      end
    end
  end
end
