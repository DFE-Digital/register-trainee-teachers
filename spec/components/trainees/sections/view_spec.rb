# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Sections
    describe View do
      alias_method :component, :page

      let(:trainees_sections_component) do
        trainee
        described_class.new(trainee: trainee, section: section)
      end

      before do
        render_inline(trainees_sections_component)
      end

      renders_confirmation = "renders confirmation"
      shared_examples renders_confirmation do |trainee_section|
        context trainee_section.to_s do
          let(:section) { trainee_section }

          it "return correct component to render" do
            expect(trainees_sections_component.component).to_not be_a(BlueInsetTextWithLink::View)
            expect(trainees_sections_component.component).to be_a(expected_confirmation_view(section))
          end
        end
      end

      renders_blue_inset_text_with_link = "renders BlueInsetTextWithLink"
      shared_examples renders_blue_inset_text_with_link do |trainee_section, status|
        context trainee_section.to_s do
          let(:section) { trainee_section }

          it "return correct component to render" do
            expect(trainees_sections_component.component).to be_a(BlueInsetTextWithLink::View)
          end

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

        include_examples renders_blue_inset_text_with_link, :personal_details, :not_started
        include_examples renders_blue_inset_text_with_link, :contact_details, :not_started
        include_examples renders_blue_inset_text_with_link, :diversity, :not_started
        include_examples renders_blue_inset_text_with_link, :degrees, :not_started
        include_examples renders_blue_inset_text_with_link, :programme_details, :not_started
        include_examples renders_blue_inset_text_with_link, :training_details, :not_started
      end

      context "trainee in progress" do
        let(:trainee) { create(:trainee, :in_progress) }

        include_examples renders_blue_inset_text_with_link, :personal_details, :in_progress
        include_examples renders_blue_inset_text_with_link, :contact_details, :in_progress
        include_examples renders_blue_inset_text_with_link, :diversity, :in_progress
        include_examples renders_blue_inset_text_with_link, :degrees, :in_progress
        include_examples renders_blue_inset_text_with_link, :programme_details, :in_progress
        include_examples renders_blue_inset_text_with_link, :training_details, :in_progress
      end

      context "trainee completed" do
        let(:trainee) do
          create(:trainee, :completed)
        end

        include_examples renders_confirmation, :personal_details
        include_examples renders_confirmation, :contact_details
        include_examples renders_confirmation, :diversity
        include_examples renders_confirmation, :degrees
        include_examples renders_confirmation, :programme_details
        include_examples renders_confirmation, :training_details
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
          training_details: {
            not_started: "edit_trainee_training_details_path",
            in_progress: "trainee_training_details_confirm_path",
          },
        }[section][status]
      end

      def expected_confirmation_view(section)
        {
          personal_details: Trainees::Confirmation::PersonalDetails::View,
          contact_details: Trainees::Confirmation::ContactDetails::View,
          diversity: Trainees::Confirmation::Diversity::View,
          degrees: Trainees::Confirmation::Degrees::View,
          programme_details: Trainees::Confirmation::ProgrammeDetails::View,
          training_details: Trainees::Confirmation::TrainingDetails::View,
        }[section]
      end
    end
  end
end
