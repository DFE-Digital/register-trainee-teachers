# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Timeline
    describe View do
      alias_method :component, :page

      let(:title) { "Title" }
      let(:username) { "User" }
      let(:date) { Time.zone.now }

      let(:event) { double(title: title, username: username, date: date) }

      before do
        render_inline(described_class.new(events: [event]))
      end

      it "displays the event title, username and date" do
        expect(component).to have_text(title)
        expect(component).to have_text(username)
        expect(component).to have_text(date.to_s(:govuk_date_and_time))
      end
    end
  end
end
