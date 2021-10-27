# frozen_string_literal: true

require "rails_helper"

module Timeline
  describe View do
    alias_method :component, :page

    let(:title) { "Trainee withdrawn" }
    let(:username) { "User" }
    let(:date) { Time.zone.now }
    let(:items) {
      [
        "#{I18n.t('components.timeline.withdrawal_date')}: #{withdrawal_date.strftime('%e %B %Y')}",
        "#{I18n.t('components.timeline.withdrawal_reason')}: #{additional_withdraw_reason}",
      ]
    }

    let(:event) { double(title: title, username: username, date: date, items: items) }
    let(:trainee) { build(:trainee, withdraw_date: withdrawal_date, withdraw_reason: withdraw_reason, additional_withdraw_reason: additional_withdraw_reason) }
    let(:withdrawal_date) { Time.zone.now + 1 }
    let(:withdraw_reason) { "for_another_reason" }
    let(:additional_withdraw_reason) { "became lazy" }

    before do
      render_inline(described_class.new(events: [event]))
    end

    it "displays the event title, username and date" do
      expect(component).to have_text(title)
      expect(component).to have_text(username)
      expect(component).to have_text(date.to_s(:govuk_date_and_time))
    end

    it "displays the reason for withdrawal" do
      expect(component).to have_text("#{I18n.t('components.timeline.withdrawal_reason')}: became lazy")
    end

    it "displays the date of withdrawal" do
      expect(component).to have_text("#{I18n.t('components.timeline.withdrawal_date')}: #{withdrawal_date.strftime('%e %B %Y')}")
    end
  end
end
