# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe Client do
    let(:url) { "http://example.com" }
    let(:mechanize) { Mechanize.new }
    let(:login_page) {
      html = read_fixture_file("hesa/login_page.html")
      Mechanize::Page.new(URI(url), nil, html, 200, mechanize)
    }
    let(:logged_in_page) {
      html = read_fixture_file("hesa/logged_in_page.html")
      Mechanize::Page.new(URI(url), nil, html, 200, mechanize)
    }

    subject { Client.new }

    before do
      allow(Settings.hesa).to receive(:username).and_return("test@example.com")
      allow(Settings.hesa).to receive(:password).and_return("test12345")
    end

    describe ".login" do
      before do
        login_form = Struct.new(:EmailAddress, :Password, :submit).new
        allow(login_form).to receive(:EmailAddress=).with(Settings.hesa.username)
        allow(login_form).to receive(:Password=).with(Settings.hesa.password)
        allow(login_form).to receive(:submit).and_return(logged_in_page)

        allow(login_page).to receive(:form_with).with(id: "loginForm").and_return(login_form)

        allow(mechanize).to receive(:get).and_return(login_page)
        allow(subject).to receive(:agent).and_return(mechanize)
      end

      it "logs in successfully" do
        expect(subject.login).to eql(logged_in_page)
      end
    end

    describe ".logged_in?" do
      it "returns true if logged in" do
        expect(subject.logged_in?(logged_in_page)).to be(true)
      end

      it "returns false if not logged in" do
        expect(subject.logged_in?(login_page)).to be(false)
      end
    end

    describe ".get" do
      let(:sample_xml) { read_fixture_file("hesa/itt_record.xml") }
      let(:sample_page) {
        Mechanize::Page.new(URI(url), nil, sample_xml, 200, mechanize)
      }

      before do
        allow(subject).to receive(:agent).and_return(mechanize)
        allow(mechanize).to receive(:get).with(url).and_return(sample_page)
        allow(subject).to receive(:login).and_return(true)
      end

      it "returns XML from URL" do
        expect(subject.get(url: url)).to eql(sample_xml)
      end
    end
  end
end
