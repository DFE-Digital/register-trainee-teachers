# frozen_string_literal: true

require "rails_helper"

module FlashBanner
  describe View do
    alias_method :component, :page

    let(:referer) { nil }
    let(:message) { "Trainee #{type}" }
    let(:type) { View::FLASH_TYPES.sample }
    let(:flash) { ActionDispatch::Flash::FlashHash.new(type => message) }
    let(:expected_title) { type == :success ? "Success" : "Important" }

    before do
      render_inline(described_class.new(flash: flash, trainee: trainee, referer: referer))
    end

    context "non draft trainee" do
      let(:trainee) { build(:trainee, :submitted_for_trn) }

      it "renders flash message" do
        expect(component).to have_text(expected_title)
        expect(component).to have_text(message)
      end
    end

    context "draft trainee" do
      let(:trainee) { build(:trainee, :draft) }

      it "doesn't render a flash message" do
        expect(component).to have_text("")
      end

      context "deleting a degree" do
        let(:referer) { "/trainees/123/degrees/confirm" }

        it "renders flash message" do
          expect(component).to have_text(expected_title)
          expect(component).to have_text(message)
        end
      end
    end
  end
end
