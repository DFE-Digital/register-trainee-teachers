# frozen_string_literal: true

require "rails_helper"

module FlashBanner
  describe View do
    alias_method :component, :page

    let(:flash) { ActionDispatch::Flash::FlashHash.new }

    %i[success warning info].each do |type|
      context "when #{type} is set" do
        let(:message) { "Trainee #{type}" }

        before do
          flash[type] = message
          render_inline(described_class.new(flash: flash))
        end

        it "renders a #{type} flash" do
          expected_title = type == :success ? "Success" : "Important"
          expect(component).to have_text(expected_title)
          expect(component).to have_text(message)
        end
      end
    end
  end
end
