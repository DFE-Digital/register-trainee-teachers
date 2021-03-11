# frozen_string_literal: true

require "rails_helper"

module FilteredBackLink
  describe View do
    alias_method :component, :page

    before do
      allow_any_instance_of(Tracker).to receive(:get_path).and_return(path)
      render_inline(described_class.new(
                      href: "/trainees",
                      text: t("views.all_records"),
                    ))
    end

    context "filtered saved path" do
      let(:path) { "/trainees?commit=Apply+filters&sort_by=&text_search=&state%5B%5D=draft&subject=All+subjects" }

      it "renders a back link" do
        expect(component).to have_link(t("views.all_records"), href: "/trainees?commit=Apply+filters&sort_by=&text_search=&state%5B%5D=draft&subject=All+subjects")
      end
    end

    context "unfiltered saved path" do
      let(:path) { "/trainees" }

      it "renders a back link" do
        expect(component).to have_link(t("views.all_records"), href: "/trainees")
      end
    end
  end
end
