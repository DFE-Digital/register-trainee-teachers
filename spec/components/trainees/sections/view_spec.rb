# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Sections
    describe View do
      alias_method :component, :page
      before do
        render_inline(described_class.new(trainee: trainee, section: section))
      end

      shared_examples "has sections" do |trainee_section, status|
        context trainee_section.to_s do
          let(:section) { trainee_section }

          it "has title" do
            expect(component).to have_css(".app-inset-text__title", text: expected_title(section, status))
          end

          it "has link" do
            expect(component).to have_link(expected_link_text(section, status), href: expected_href(section, status, trainee))
          end
        end
      end

      context "trainee not started" do
        let(:trainee) { create(:trainee, :not_started) }

        include_examples "has sections", :personal_details, :not_started
        include_examples "has sections", :contact_details, :not_started
        include_examples "has sections", :diversity, :not_started
        include_examples "has sections", :degrees, :not_started
        include_examples "has sections", :programme_details, :not_started
      end

      context "trainee in progress" do
        let(:trainee) { create(:trainee, :in_progress) }

        include_examples "has sections", :personal_details, :in_progress
        include_examples "has sections", :contact_details, :in_progress
        include_examples "has sections", :diversity, :in_progress
        include_examples "has sections", :degrees, :in_progress
        include_examples "has sections", :programme_details, :in_progress
      end

      def expected_title(section, status)
        I18n.t("components.sections.#{section}.#{status}.title")
      end

      def expected_link_text(section, status)
        I18n.t("components.sections.#{section}.#{status}.link_text")
      end

      def expected_href(section, status, trainee)
        path = expected_path(section, status)
        Rails.application.routes.url_helpers.public_send(path, trainee)
      end

      def expected_path(section, status)
        {
          personal_details: {
            not_started: "edit_trainee_personal_details_path",
            in_progress: "trainee_personal_details_confirm_path",
          },
          contact_details: {
            not_started: "edit_trainee_contact_details_path",
            in_progress: "trainee_contact_details_confirm_path",
          },
          diversity: {
            not_started: "edit_trainee_diversity_disability_disclosure_path",
            in_progress: "trainee_diversity_confirm_path",
          },
          degrees: {
            not_started: "trainee_degrees_new_type_path",
            in_progress: "trainee_degrees_confirm_path",
          },
          programme_details: {
            not_started: "edit_trainee_programme_details_path",
            in_progress: "trainee_programme_details_confirm_path",
          },
        }[section][status]
      end
    end
  end
end
